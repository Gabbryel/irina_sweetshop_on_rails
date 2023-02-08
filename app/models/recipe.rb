  class Recipe < ApplicationRecord
  belongs_to :category
  has_many :cakemodels, dependent: :destroy
  has_many :model_components, dependent: :destroy
  has_one_attached :photo
  validates :name, presence: true
  validates :content, presence: true
  # validates :photo, presence: true
  after_save :slugify, unless: :check_slug
  include Reviewable
  include RatingsConcern
  include SlugHelper

  monetize :price_cents
  
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

end