module SiteSettingsHelper
  def site_setting(key, default = nil)
    SiteSetting.get(key, default)
  end
  
  def navbar_color
    site_setting('navbar_color', '#1a5c44') # Default to jungle green
  end
end
