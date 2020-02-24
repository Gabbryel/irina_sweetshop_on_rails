class Review < ApplicationRecord
  belongs_to :user
  belongs_to :recipe
  validates :user_id, uniqueness: { scope: :recipe }
  validates :rating, presence: true
  validates :content, presence: true
  validates :content, length: { minimum: 10 }
  validates :content, length: { maximum: 50 }
end
