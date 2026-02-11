class Item < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :cart
  belongs_to :recipe, optional: true
  belongs_to :cakemodel, optional: true
  has_many :item_extras, dependent: :destroy
  accepts_nested_attributes_for :item_extras, allow_destroy: true

  monetize :price_cents
  monetize :total_cents

  before_validation :set_default_quantity
  before_save :recalculate_totals

  def total
    total_cents_money
  end

  def total_cents_money
    if total_cents.present? && total_cents.positive?
      Money.new(total_cents, Money.default_currency)
    else
      price * quantity
    end
  end

  def increment_quantity!(value)
    self.quantity = (quantity || 0) + value
    save!
  end

  private

  def set_default_quantity
    self.quantity = 1 if quantity.blank?
  end

  def recalculate_totals
    base_total = (quantity.to_f * price_cents.to_i).round
    extras_sum_per_unit = item_extras.to_a.sum { |ie| ie.price_cents.to_i }
    extras_total = (quantity.to_f * extras_sum_per_unit).round
    self.total_cents = base_total + extras_total
  end
end
