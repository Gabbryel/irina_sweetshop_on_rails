class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @recipes = policy_scope(Recipe).where(category_id: params[:category_id])
  end
end
