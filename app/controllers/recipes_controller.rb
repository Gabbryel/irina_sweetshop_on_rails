class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_category, only: [:new, :create, :edit, :destroy]
  before_action :set_recipe, only: [:edit, :update, :destroy]
  
  def new
    @recipe = authorize Recipe.new
    @page_title = "Rețetă nouă de #{@category.name.downcase}- Cofetăria Irina - Bacău"
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
    @page_title = "Rețete de #{ Category.find(params[:category_id]).name.downcase }"
  end

  def show
    @recipe = Recipe.friendly.find(params[:id])
    @review = Review.new
    @reviews = @recipe.reviews.all
    @page_title = "Rețeta de #{ @recipe.name } || Cofetăria Irina - Bacău"
    @seo_keywords = @recipe.content
  end

  def edit
    @page_title = 'Modifică rețeta - Cofetăria Irina - Bacău'
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
    @category = Category.where(slug: params[:id])
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
    authorize @recipe
  end
end
