class Category < ApplicationRecord
  has_one_attached :photo
  has_many :recipes, dependent: :destroy
  has_many :cakemodels, dependent: :destroy
  has_many :designs, dependent: :destroy
  validates :name, presence: true
  # validates :photo, presence: true
  after_save :slugify, unless: :check_slug
  include SlugHelper

  def to_param
    "#{slug}"
  end

  def menu_like?
    return false unless has_attribute?(:menu_like)

    self[:menu_like]
  end

end
