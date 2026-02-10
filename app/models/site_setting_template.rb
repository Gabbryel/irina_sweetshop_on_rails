class SiteSettingTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :settings, presence: true
  
  # Callback to ensure only one template is active at a time
  before_save :deactivate_others, if: :active?
  
  # Create a template from current settings
  def self.create_from_current(name, description = nil)
    settings_hash = {}
    SiteSetting.all.each do |setting|
      settings_hash[setting.key] = setting.value
    end
    
    create(
      name: name,
      description: description,
      settings: settings_hash,
      active: false
    )
  end
  
  # Apply this template's settings
  def apply!
    return false unless settings.present?
    
    settings.each do |key, value|
      SiteSetting.set(key, value)
    end
    
    # Mark this template as active
    self.class.update_all(active: false)
    update(active: true)
    true
  end
  
  private
  
  def deactivate_others
    self.class.where.not(id: id).update_all(active: false)
  end
end
