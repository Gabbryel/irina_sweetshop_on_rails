class Recipe < ApplicationRecord
  belongs_to :category
  has_one_attached :photo
  validates :name, presence: true
  validates :content, presence: true
  validates :photo, presence: true

  include Reviewable
  
  def overall_rating
    ratings = []
    self.reviews.each do |rev|
      ratings << rev.rating
    end
    ratings.count == 0 ? "" : ratings.sum / ratings.count.to_f
  end
end