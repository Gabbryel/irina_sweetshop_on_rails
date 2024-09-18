class Cakemodel < ApplicationRecord
  has_one_attached :photo
  has_many :model_images, dependent: :destroy
  has_many :model_components, dependent: :destroy
  has_rich_text :content
  belongs_to :category
  belongs_to :design

  validates :name, presence: true
  validates :photo, presence: true

  after_save :slugify, unless: :check_slug
  include RatingsConcern
  include Reviewable
  include SlugHelper

  self.ignored_columns = ["recipe_id"]

  def to_param
    "#{slug}"
  end

  def overall_rating
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end

  def no_of_ratings
    ratings.count == 1 ? "(#{ratings.count} recenzie)" : "(#{ratings.count} recenzii)"
  end
end
