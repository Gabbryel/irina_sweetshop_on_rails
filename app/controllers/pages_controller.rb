class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :how_to_order, :about, :valori_nutritionale]

  def home
    @recipes = Recipe.where(favored: true).order(position: :asc).first(8)
    @features = Feature.all.order(:id)
    @categories = Category.all.order(:id)
  end

  def recepies
  end

  def how_to_order
    @page_main_title = 'Cum comand?'
  end

  def about
    @page_main_title = 'Despre noi'
  end

  def valori_nutritionale
    @page_main_title = 'Valori nutriționale'
    @categories = Category.all.order(:name)
  end

  def admin_dashboard
  end
end
