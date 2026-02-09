module Dashboard
  module Design
    class HeroSectionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_hero_section
      before_action :authorize_hero_section

      def show
        redirect_to edit_dashboard_design_hero_section_path
      end

      def edit
        @page_title = 'Editare Hero Section ・ Cofetăria Irina'
        @page_main_title = 'Editare Hero Section'
      end

      def update
        if @hero_section.update(hero_section_params)
          redirect_to edit_dashboard_design_hero_section_path, notice: 'Hero section actualizat cu succes.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_hero_section
        @hero_section = HeroSection.first_or_create!(
          title: 'Deserturi proaspete',
          subtitle: 'în fiecare zi',
          button_text: 'Vezi produsele',
          button_link: '/categories'
        )
      end

      def authorize_hero_section
        authorize @hero_section
      end

      def hero_section_params
        params.require(:hero_section).permit(:title, :subtitle, :button_text, :button_link, :background_image_url, :chocolate_color)
      end
    end
  end
end
