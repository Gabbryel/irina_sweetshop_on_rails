class HeroSection < ApplicationRecord
  has_one_attached :main_image
  has_one_attached :background_image

  validates :title, :subtitle, presence: true
  validates :button_text, presence: true
  validates :button_link, presence: true
end
