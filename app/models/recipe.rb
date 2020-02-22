class Recipe < ApplicationRecord
  belongs_to :category
  has_one_attached :photo
  has_many :reviews, dependent: :destroy
  validates :name, presence: true
  validates :content, presence: true
  validates :photo, presence: true
  
  def overall_rating
    ratings = []
    self.reviews.each do |rev|
      ratings << rev.rating
    end
    ratings.count == 0 ? "" : ratings.sum / ratings.count
  end
end
