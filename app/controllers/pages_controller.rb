class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def recepies
  end

  def how_to_order
  end

  def about
  end
end
