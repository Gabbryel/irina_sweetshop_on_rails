class Review < ApplicationRecord
  belongs_to :user
  belongs_to :recipe
  validates :rating, presence: true
  validates :content, presence: true
  validates :content, length: { minimum: 20 }
  validates :content, length: { maximum: 100 }
end
