class SiteSetting < ApplicationRecord
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
end
