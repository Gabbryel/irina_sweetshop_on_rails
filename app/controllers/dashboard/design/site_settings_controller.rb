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
        
        @navbar_color = SiteSetting.find_by(key: 'navbar_color')
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

      private

      def authorize_site_settings
        authorize :site_setting, :manage?
      end

      def initialize_default_settings
        # Create default navbar color if it doesn't exist
        unless SiteSetting.exists?(key: 'navbar_color')
          SiteSetting.set('navbar_color', '#f8f9fa', 'Culoarea de fundal a barei de navigare')
        end
      end
    end
  end
end
