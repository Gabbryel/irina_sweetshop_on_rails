require 'bigdecimal'

class Recipe < ApplicationRecord
  SOLD_BY_OPTIONS = %w[kg buc].freeze

  belongs_to :category
  has_many :cakemodels
  has_many :model_components, dependent: :destroy
  has_many :extras, dependent: :destroy
  has_one_attached :photo
  accepts_nested_attributes_for :extras, allow_destroy: true
  validates :name, presence: true
  validates :content, presence: true
  validates :sold_by, inclusion: { in: SOLD_BY_OPTIONS }
  validates :online_selling_weight, presence: true, numericality: { greater_than: 0 }, if: :requires_online_selling_weight?
  # validates :photo, presence: true
  after_save :slugify, unless: :check_slug
  include Reviewable
  include RatingsConcern
  include SlugHelper

  # whether this recipe exposes extras for ordering
  def has_extras?
    self[:has_extras] || extras.any?
  end

  monetize :price_cents
  monetize :online_selling_price_cents, allow_nil: true

  before_validation :normalize_sale_configuration
  before_validation :compute_online_selling_price

  scope :online_for_order, -> { where(online_order: true, publish: true) }

  validate :ensure_online_order_configuration
  
  def to_param
    "#{slug}"
  end
  
  def overall_rating
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end
  
  def no_of_ratings
    ratings.count == 0 ? "Fără recenzii, scrie tu una!" :
    ratings.count == 1 ? "#{ratings.count} recenzie" :
    "#{ratings.count} recenzii"
  end

  def supports_online_ordering?
    online_order? && publish? && price_cents.to_i.positive?
  end

  def weight_quantity_value
    weight_quantity
  end

  def kg_quantity_value
    kg_quantity
  end

  def per_piece_sale?
    kg_buc.to_s.casecmp('kg').zero? && sold_by.to_s.casecmp('buc').zero?
  end

  private

  def compute_online_selling_price
    return if price_cents.blank?

    base_price = price_cents.to_i
    calculated_price = if per_piece_sale?
                         weight = safe_decimal(online_selling_weight)
                         (BigDecimal(base_price.to_s) * weight).round
                       else
                         base_price
                       end

    self.online_selling_price_cents = calculated_price.positive? ? calculated_price : 0
  end

  def ensure_online_order_configuration
    return unless online_order?

    if price_cents.to_i <= 0
      errors.add(:price_cents, 'trebuie completat pentru produsele disponibile online.')
    end

    if per_piece_sale? && !online_selling_weight.to_f.positive?
      errors.add(:online_selling_weight, 'trebuie completată pentru produsele vândute la bucată.')
    end

  end

  def kg_quantity
    raw = kg_buc.to_s.strip
    numeric = raw[/[0-9]+([\.,][0-9]+)?/]
    return BigDecimal('0') if numeric.blank?

    value = BigDecimal(numeric.tr(',', '.'))
    value.positive? ? value : BigDecimal('0')
  rescue ArgumentError
    BigDecimal('0')
  end

  def weight_quantity
    value = safe_decimal(weight)
    value.positive? ? value : BigDecimal('0')
  end

  def normalize_sale_configuration
    self.sold_by = sold_by.presence&.downcase || 'kg'

    self.online_selling_weight = nil unless per_piece_sale?
  end

  def requires_online_selling_weight?
    per_piece_sale?
  end

  def safe_decimal(value)
    BigDecimal(value.to_s)
  rescue ArgumentError
    BigDecimal('0')
  end

end