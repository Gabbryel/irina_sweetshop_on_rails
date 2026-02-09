class HeroSection < ApplicationRecord
  validates :title, :subtitle, :button_text, :button_link, presence: true
  validates :chocolate_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true
  
  before_save :set_default_chocolate_color
  
  private
  
  def set_default_chocolate_color
    self.chocolate_color ||= '#3d2817'
  end
end
