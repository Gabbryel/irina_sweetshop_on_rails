class Category < ApplicationRecord
  has_one_attached :photo
  has_many :recipes, dependent: :destroy
  has_many :cakemodels, dependent: :destroy
  validates :name, presence: true
  # validates :photo, presence: true
end
