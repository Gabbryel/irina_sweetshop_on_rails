class Review < ApplicationRecord
  belongs_to :user
  belongs_to :reviewable, :polymorphic => true
  validates :rating, presence: true
  validates :content, presence: true
  validates :content, length: { minimum: 10 }
  validates :content, length: { maximum: 50 }
end
