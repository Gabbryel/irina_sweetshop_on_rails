class Cakemodel < ApplicationRecord
  belongs_to :category
  has_one_attached :photo
  
  include Reviewable
  
  validates :content, presence: true
  validates :photo, presence: true
end
