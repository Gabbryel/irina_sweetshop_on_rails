class Cakemodel < ApplicationRecord
  require 'bigdecimal'

  attr_accessor :initial_recipe_id
  attribute :available_for_delivery, :boolean, default: true

  has_one_attached :photo
  has_many :model_images, dependent: :destroy
  has_many :model_components, dependent: :destroy
  has_many :items, dependent: :nullify
  has_rich_text :content
  belongs_to :category
  belongs_to :design

  validates :name, presence: true
  validates :photo, presence: true
  validates :initial_recipe_id, presence: { message: 'trebuie selectata la creare' }, on: :create
  validates :available_online, inclusion: { in: [true, false], message: 'trebuie selectat' }
  validates :available_for_delivery, inclusion: { in: [true, false], message: 'trebuie selectat' }
  validates :price_per_kg, :price_per_piece, :final_price, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :display_order, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true, if: -> { has_attribute?(:display_order) }

  before_validation :normalize_integer_price_fields
  before_validation :prefill_pricing_fields
  after_save :slugify, unless: :check_slug
  include RatingsConcern
  include Reviewable
  include SlugHelper

  self.ignored_columns = ["recipe_id", "cake_recipe_id"]

  def to_param
    "#{slug}"
  end

  def overall_rating
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end

  def no_of_ratings
    ratings.count == 1 ? "(#{ratings.count} recenzie)" : "(#{ratings.count} recenzii)"
  end

  private

  def prefill_pricing_fields
    pricing_recipe = recipe_for_pricing
    return unless pricing_recipe && design.present?

    design_price_per_kg = money_to_decimal(design.price)
    recipe_price_per_kg = money_to_decimal(pricing_recipe.price)
    derived_price_per_kg = (design_price_per_kg + recipe_price_per_kg).round(0)

    weight_decimal = decimal_or_zero(weight)
    kg_weight = weight_decimal.positive? ? (weight_decimal / BigDecimal('1000')) : BigDecimal('0')
    derived_price_per_piece = (derived_price_per_kg * kg_weight).round(0)

    self.price_per_kg = derived_price_per_kg if price_per_kg.blank?
    self.price_per_piece = derived_price_per_piece if price_per_piece.blank?
    self.final_price = derived_price_per_piece if final_price.blank?
  end

  def normalize_integer_price_fields
    self.price_per_kg = normalize_integer(price_per_kg)
    self.price_per_piece = normalize_integer(price_per_piece)
    self.final_price = normalize_integer(final_price)
    self.display_order = normalize_integer(display_order) || 0 if has_attribute?(:display_order)
  end

  def recipe_for_pricing
    selected_recipe_id = initial_recipe_id.presence
    return Recipe.find_by(id: selected_recipe_id) if selected_recipe_id

    model_components.includes(:recipe).order(:id).first&.recipe
  end

  def money_to_decimal(value)
    return BigDecimal('0') if value.blank?
    return value.to_d if value.respond_to?(:to_d)

    BigDecimal(value.to_s)
  rescue ArgumentError
    BigDecimal('0')
  end

  def decimal_or_zero(value)
    return BigDecimal('0') if value.blank?

    BigDecimal(value.to_s)
  rescue ArgumentError
    BigDecimal('0')
  end

  def normalize_integer(value)
    return nil if value.blank?

    BigDecimal(value.to_s).round(0).to_i
  rescue ArgumentError
    nil
  end
end
