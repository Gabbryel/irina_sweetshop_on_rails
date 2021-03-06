class Cakemodel < ApplicationRecord
  belongs_to :category
  has_one_attached :photo
  validates :name, presence: true
  validates :content, presence: true
  validates :photo, presence: true
  include RatingsConcern
  include Reviewable

  def overall_rating
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end

  def no_of_ratings
    ratings.count == 1 ? "(#{ratings.count} recenzie)" : "(#{ratings.count} recenzii)"
  end
end
