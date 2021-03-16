class Cakemodel < ApplicationRecord
  belongs_to :category
  has_one_attached :photo
  validates :content, presence: true
  validates :photo, presence: true
  
  include Reviewable

  def name
    "Model ##{id}"
  end

  def overall_rating
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end

  def no_of_ratings
    ratings.count == 1 ? "(#{ratings.count} recenzie)" : "(#{ratings.count} recenzii)"
  end

  private

  def ratings
    ratings = []
    self.reviews.each { |rev| ratings << rev.rating}
    ratings
  end
end
