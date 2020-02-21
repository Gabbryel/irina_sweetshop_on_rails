class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  
  def index
    @recipes = policy_scope(Recipe).where(category_id: params[:category_id])
  end

  def new
    @category = Category.find(params[:category_id])
    @recipe = Recipe.new
    authorize @recipe
  end

  def create
    @category = Category.find(params[:category_id])
    @recipe = Recipe.new(recipe_params)
    @recipe.category = @category
    if @recipe.save
      redirect_to category_recipes_path(params[:category_id])
    else
      render :new
    end
    authorize @recipe
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @category = Category.find(params[:category_id])
    authorize @recipe
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.update(recipe_params)
    authorize @recipe
    redirect_to category_recipes_path(params[:category_id])
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @category = Category.find(params[:category_id])
    @recipe.destroy
    authorize @recipe
    redirect_to category_recipes_path(params[:category_id])
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content, :photo)
  end

  def set_category_and_recipe
  end
end
