class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :how_to_order, :about]

  def home
  end

  def recepies
  end

  def how_to_order
    @page_main_title = 'Cum comand?'
  end

  def about
    @page_main_title = 'Despre noi'
  end

  def admin_dashboard
  end
end
