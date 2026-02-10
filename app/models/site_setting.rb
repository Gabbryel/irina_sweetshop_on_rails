class SiteSetting < ApplicationRecord
  has_one_attached :hero_image
  
  validates :key, presence: true, uniqueness: true
  
  # Class method to get a setting value
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting&.value || default
  end
  
  # Class method to set a setting value
  def self.set(key, value, description = nil)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.description = description if description
    setting.save
    setting
  end
  
  # Get the hero image attachment
  def self.hero_image_attachment
    hero_setting = find_or_create_by(key: 'hero_image_uploaded') do |s|
      s.description = 'Hero section uploaded image'
      s.value = 'false'
    end
    hero_setting
  end
end
