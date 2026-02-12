module Dashboard
  module Design
    class SiteSettingsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_site_settings

      def index
        @page_title = 'Setări Design Site ・ Cofetăria Irina'
        @page_main_title = 'Setări Design Site'
        
        # Initialize default settings if they don't exist
        initialize_default_settings

        @site_settings = policy_scope(SiteSetting)
        @navbar_color = @site_settings.find_by(key: 'navbar_color')
        @hero_wave_color = @site_settings.find_by(key: 'hero_wave_color')
        @hero_bottom_wave_color = @site_settings.find_by(key: 'hero_bottom_wave_color')
        @hero_background_color = @site_settings.find_by(key: 'hero_background_color')
        @hero_image_url = @site_settings.find_by(key: 'hero_image_url')
        @hero_image_max_width_mobile = @site_settings.find_by(key: 'hero_image_max_width_mobile')
        @hero_image_max_width_tablet = @site_settings.find_by(key: 'hero_image_max_width_tablet')
        @hero_image_max_width_desktop = @site_settings.find_by(key: 'hero_image_max_width_desktop')
        @hero_image_setting = SiteSetting.hero_image_attachment
        @hero_text_line1 = @site_settings.find_by(key: 'hero_text_line1')
        @hero_text_line2 = @site_settings.find_by(key: 'hero_text_line2')
        @hearts_animation_enabled = @site_settings.find_by(key: 'hearts_animation_enabled')
        @card_container_recipes_background_color = @site_settings.find_by(key: 'card_container_recipes_background_color')
        
        # Load templates
        @templates = policy_scope(SiteSettingTemplate).order(created_at: :desc)
      end

      def update
        setting_key = params[:site_setting][:key]
        setting_value = params[:site_setting][:value]
        setting_description = params[:site_setting][:description]
        
        if SiteSetting.set(setting_key, setting_value, setting_description)
          redirect_to dashboard_design_site_settings_path, notice: 'Setările au fost actualizate cu succes.'
        else
          redirect_to dashboard_design_site_settings_path, alert: 'A apărut o eroare la actualizarea setărilor.'
        end
      end
      
      def upload_hero_image
        authorize :site_setting, :manage?
        
        hero_setting = SiteSetting.hero_image_attachment
        
        if params[:hero_image].present?
          hero_setting.hero_image.attach(params[:hero_image])
          hero_setting.update(value: 'uploaded')
          redirect_to dashboard_design_site_settings_path, notice: 'Imaginea a fost încărcată cu succes.'
        else
          redirect_to dashboard_design_site_settings_path, alert: 'Te rog selectează o imagine.'
        end
      end
      
      def remove_hero_image
        authorize :site_setting, :manage?
        
        hero_setting = SiteSetting.hero_image_attachment
        
        if hero_setting.hero_image.attached?
          # Purge immediately (synchronous)
          hero_setting.hero_image.purge
          
          redirect_to dashboard_design_site_settings_path, notice: 'Imaginea încărcată a fost ștearsă. Acum se folosește setarea URL.'
        else
          redirect_to dashboard_design_site_settings_path, alert: 'Nu există imagine încărcată de șters.'
        end
      end
      
      def create_template
        authorize SiteSettingTemplate, :create?
        
        template = SiteSettingTemplate.create_from_current(
          params[:template_name],
          params[:template_description]
        )
        
        if template.persisted?
          redirect_to dashboard_design_site_settings_path, notice: "Template '#{template.name}' a fost salvat cu succes."
        else
          redirect_to dashboard_design_site_settings_path, alert: "Eroare la salvarea template-ului: #{template.errors.full_messages.join(', ')}"
        end
      end
      
      def apply_template
        template = SiteSettingTemplate.find(params[:id])
        authorize template, :apply?
        
        if template.apply!
          redirect_to dashboard_design_site_settings_path, notice: "Template '#{template.name}' a fost aplicat cu succes."
        else
          redirect_to dashboard_design_site_settings_path, alert: 'Eroare la aplicarea template-ului.'
        end
      end
      
      def destroy_template
        template = SiteSettingTemplate.find(params[:id])
        authorize template, :destroy?
        
        if template.destroy
          redirect_to dashboard_design_site_settings_path, notice: 'Template-ul a fost șters cu succes.'
        else
          redirect_to dashboard_design_site_settings_path, alert: 'Eroare la ștergerea template-ului.'
        end
      end

      private

      def authorize_site_settings
        authorize :site_setting, :manage?
      end

      def initialize_default_settings
        # Create default navbar color if it doesn't exist
        unless SiteSetting.exists?(key: 'navbar_color')
          SiteSetting.set('navbar_color', '#f8f9fa', 'Culoarea de fundal a barei de navigare')
        end
        
        # Create default hero wave color if it doesn't exist
        unless SiteSetting.exists?(key: 'hero_wave_color')
          SiteSetting.set('hero_wave_color', '#f36a3e', 'Culoarea wave-ului de sub navbar')
        end
        
        # Create default hero image settings if they don't exist
        unless SiteSetting.exists?(key: 'hero_image_url')
          SiteSetting.set('hero_image_url', 'ecler_sgmmrc.webp', 'URL sau Cloudinary public_id pentru imaginea hero')
        end
        
        unless SiteSetting.exists?(key: 'hero_image_max_width')
          SiteSetting.set('hero_image_max_width', '90', 'Lățimea maximă a imaginii hero ca procent (ex: 90 pentru 90%)')
        end

        unless SiteSetting.exists?(key: 'card_container_recipes_background_color')
          SiteSetting.set('card_container_recipes_background_color', '#fff6d9', 'Culoarea de fundal pentru cardurile de rețete și modele tort')
        end
      end
    end
  end
end
