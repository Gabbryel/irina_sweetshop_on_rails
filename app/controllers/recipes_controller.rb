class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_category, only: [:new, :create, :edit, :destroy]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  
  def new
    @recipe = Recipe.new
    authorize @recipe
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.category = @category
    if @recipe.save
      redirect_to category_recipes_path(params[:category_id])
    else
      render :new
    end
    authorize @recipe
  end
  
  def index
    @recipes = policy_scope(Recipe).where(category_id: params[:category_id])
  end

  def show
    @review = Review.new
    @reviews = @recipe.reviews.all
  end



  def edit
  end

  def update
    @recipe.update(recipe_params)
    redirect_to category_recipes_path(params[:category_id])
  end

  def destroy
    @recipe.destroy
    redirect_to category_recipes_path(params[:category_id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content, :photo)
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
    authorize @recipe
  end
end
