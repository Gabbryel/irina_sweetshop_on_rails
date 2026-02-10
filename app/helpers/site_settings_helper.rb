module SiteSettingsHelper
  def site_setting(key, default = nil)
    SiteSetting.get(key, default)
  end
  
  def navbar_color
    site_setting('navbar_color', '#1a5c44') # Default to jungle green
  end
  
  def hero_wave_color
    site_setting('hero_wave_color', '#f36a3e') # Default to orange
  end
  
  def hero_bottom_wave_color
    site_setting('hero_bottom_wave_color', '#f36a3e') # Default to orange
  end
  
  def hero_background_color
    site_setting('hero_background_color', '#E0A458') # Default to earth yellow
  end
  
  def hero_image_url
    # Check if there's an uploaded image first
    hero_setting = SiteSetting.hero_image_attachment
    if hero_setting.hero_image.attached?
      return :uploaded
    end
    
    # Fall back to URL setting
    site_setting('hero_image_url', 'ecler_sgmmrc.webp')
  end
  
  def hero_image_max_width_mobile
    site_setting('hero_image_max_width_mobile', '85').to_i
  end
  
  def hero_image_max_width_tablet
    site_setting('hero_image_max_width_tablet', '75').to_i
  end
  
  def hero_image_max_width_desktop
    site_setting('hero_image_max_width_desktop', '60').to_i
  end
  
  def hero_image_attachment
    SiteSetting.hero_image_attachment
  end
  
  def hero_text_line1
    site_setting('hero_text_line1', 'Deserturi proaspete')
  end
  
  def hero_text_line2
    site_setting('hero_text_line2', 'în fiecare zi')
  end
  
  def hearts_animation_enabled?
    site_setting('hearts_animation_enabled', 'true') == 'true'
  end
end
