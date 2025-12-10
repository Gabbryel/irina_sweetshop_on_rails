class Cart < ApplicationRecord
  STATUSES = {
    no_status: "no_status",
    seen: "seen",
    in_production: "in_production",
    ready: "ready",
    delivered: "delivered",
    canceled: "canceled",
    refunded: "refunded"
  }.freeze

  COUNTIES = ['Bacău', 'Neamț', 'mun. București'].freeze
  DELIVERY_METHODS = %w[delivery pickup].freeze
  MAX_DELIVERY_WINDOW_DAYS = 30

  STATUS_LABELS = {
    "no_status" => "Pending · Neplătită",
    "seen" => "Văzută",
    "in_production" => "În producție",
    "ready" => "Gata de livrare",
    "delivered" => "Livrată",
    "canceled" => "Anulată",
    "refunded" => "Rambursată"
  }.freeze

  belongs_to :user, optional: true
  has_many :items, -> { order(created_at: :asc) }, dependent: :destroy

  enum status: STATUSES, _suffix: true

  before_create :ensure_guest_token
  before_create :default_status
  before_update :stamp_status_timestamps, if: :will_save_change_to_status?

  validates :customer_full_name, :customer_phone, presence: true, if: :requires_customer_details?
  validates :delivery_address, presence: true, if: -> { requires_customer_details? && method_of_delivery == 'delivery' }
  validates :county, inclusion: { in: COUNTIES }, allow_blank: true
  validates :method_of_delivery, inclusion: { in: DELIVERY_METHODS }, allow_blank: true
  validate :validate_delivery_requirements
  validate :validate_delivery_date

  def self.fetch_for_user(user, session)
    current_cart = user_cart(user)
    guest_cart = guest_cart_from_session(session)

    if guest_cart.present?
      if current_cart.present?
        current_cart.absorb!(guest_cart)
      else
        guest_cart.update!(user: user, guest_token: nil)
        current_cart = guest_cart
      end
      session.delete(:cart_token)
    end

    current_cart ||= create!(user: user)
    current_cart.update!(guest_token: nil) if current_cart.guest_token.present?
    current_cart
  end

  def self.fetch_for_guest(session)
    guest_cart_from_session(session)
  end

  def self.user_cart(user)
    return nil unless user

    user.carts.where(status: [STATUSES[:no_status], STATUSES[:seen], STATUSES[:in_production], STATUSES[:ready]]).order(created_at: :desc).first
  end

  def self.guest_cart_from_session(session)
    token = session[:cart_token]
    return nil if token.blank?

    Cart.where(guest_token: token, status: [STATUSES[:no_status], STATUSES[:seen], STATUSES[:in_production], STATUSES[:ready]]).order(created_at: :desc).first
  end

  def total_cents
    items.to_a.sum do |item|
      cents = item.total_cents.to_i
      cents.positive? ? cents : (item.quantity.to_f * item.price_cents.to_i).round
    end
  end

  def total_money
    Money.new(total_cents || 0, Money.default_currency)
  end

  def grand_total
    total_money
  end

  def absorb!(other_cart)
    return if other_cart.blank? || other_cart == self

    other_cart.items.update_all(cart_id: id)
    other_cart.destroy
  end

  def register_checkout_session!(session_id:, payment_intent: nil)
    update!(stripe_checkout_session_id: session_id,
      stripe_payment_intent_id: payment_intent,
      status: STATUSES[:no_status])
  end

  def customer_name
    customer_full_name.presence || user&.try(:name) || user&.email || 'Vizitator'
  end

  def contact_email
    email.presence || user&.email
  end

  def status_label
    value = status.to_s.presence || STATUSES[:no_status]
    STATUS_LABELS[value] || value.titleize
  end

  def status_badge_variant
    case status
    when STATUSES[:no_status]
      'info'
    # Orange for current/active statuses
    when STATUSES[:seen], STATUSES[:in_production], STATUSES[:ready]
      'warning'
    # Green for done/successful
    when STATUSES[:delivered]
      'success'
    # Red for terminal/next problem states
    when STATUSES[:canceled], STATUSES[:refunded]
      'danger'
    else
      'secondary'
    end
  end

  def line_item_count
    items.size
  end

  def requires_pickup_only?
    items.joins(:recipe).where(recipes: { only_pickup: true }).exists?
  end

  # Public-facing order number used for guests and printed confirmations
  # Example: IRINA-000123
  def public_order_number
    "IRINA-#{id.to_i.to_s.rjust(6, '0')}"
  end

  def total_quantity
    items.sum { |item| item.quantity.to_f }
  end

  def earliest_delivery_date(reference_date = Date.current)
    base_date = reference_date + 1.day
    lead_values = items.includes(:recipe).map { |item| item.recipe&.disable_delivery_for_days }
    lead_time_days = lead_values.compact.max || 0
    base_date + lead_time_days
  end

  def delivery_blocked_dates(reference_date = Date.current)
    earliest_date = earliest_delivery_date(reference_date)
    lead_window_start = reference_date + 1.day

    lead_time_range = if earliest_date > lead_window_start
                        (lead_window_start...earliest_date).to_a
                      else
                        []
                      end

    (lead_time_range + DeliveryCalendar.disabled_dates(reference_date)).uniq.sort
  end

  def delivery_window(reference_date: Date.current)
    Cart::DeliveryWindow.new(
      min_date: earliest_delivery_date(reference_date),
      max_date: reference_date + MAX_DELIVERY_WINDOW_DAYS.days,
      blocked_dates: delivery_blocked_dates(reference_date),
      max_window_days: MAX_DELIVERY_WINDOW_DAYS
    )
  end

  private

  def requires_customer_details?
    # For the new status lifecycle, require customer details
    # once the order has been seen (or later).
    seen_status? || in_production_status? || ready_status? || delivered_status?
  end

  def ensure_guest_token
    self.guest_token ||= SecureRandom.uuid if user_id.blank?
  end

  def default_status
    self.status ||= STATUSES[:no_status]
  end

  def stamp_status_timestamps
    case status
    when STATUSES[:delivered]
      self.fulfilled_at ||= Time.current
      self.cancelled_at = nil
    when STATUSES[:canceled], STATUSES[:refunded]
      self.cancelled_at ||= Time.current
      self.fulfilled_at = nil
    else
      self.fulfilled_at = nil
      self.cancelled_at = nil
    end
  end

  def validate_delivery_requirements
    return if method_of_delivery.blank? && delivery_date.blank? && county.blank? && delivery_address.blank?

    if method_of_delivery.blank?
      errors.add(:method_of_delivery, 'trebuie selectată')
    end

    if delivery_date.blank?
      errors.add(:delivery_date, 'trebuie completată')
    end

    if method_of_delivery == 'delivery'
      errors.add(:delivery_address, 'trebuie completată pentru livrare') if delivery_address.blank?
      errors.add(:county, 'trebuie selectat pentru livrare') if county.blank?
      if items.size <= 1
        errors.add(:base, 'Pentru livrare trebuie să comanzi cel puțin două produse.')
      end
    end
  end

  def validate_delivery_date
    return if delivery_date.blank?

    reference_date = created_at&.to_date || Date.current
    today = Date.current

    if delivery_date < today
      errors.add(:delivery_date, 'nu poate fi în trecut')
      return
    end

    earliest = earliest_delivery_date(reference_date)

    if delivery_date < earliest
      errors.add(:delivery_date, "trebuie să fie cel puțin începând cu #{I18n.l(earliest)}")
    end

    max_allowed = today + MAX_DELIVERY_WINDOW_DAYS.days
    if delivery_date > max_allowed
      errors.add(:delivery_date, "trebuie să fie în următoarele #{MAX_DELIVERY_WINDOW_DAYS} zile")
    end

    blocked_dates = delivery_blocked_dates(reference_date)
    if blocked_dates.include?(delivery_date)
      errors.add(:delivery_date, 'nu este disponibilă pentru livrare')
    end
  rescue ArgumentError
    errors.add(:delivery_date, 'nu este o dată validă')
  end

end
