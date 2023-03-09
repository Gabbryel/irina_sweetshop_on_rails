class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_category
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  
  def new
    @recipe = authorize Recipe.new
    @page_title = "Rețetă nouă de #{@category.name.downcase}- Cofetăria Irina - Bacău"
  end

  def create
    @recipe = authorize Recipe.new(recipe_params)
    @recipe.category = @category
    if @recipe.save
      redirect_to category_recipes_path(@category)
    else
      render :new
    end
  end
  
  def index
    @recipes = policy_scope(Recipe).where(category_id: @category, publish: true).order('name ASC')
    @page_title = "Rețete de #{ @category.name.downcase }"
  end

  def show
    @item = Item.new
    @review = Review.new
    @reviews = @recipe.reviews.all
    @page_title = "Rețeta de #{ @recipe.name } || Cofetăria Irina - Bacău"
    @seo_keywords = @recipe.content
    @recipes = policy_scope(Recipe).where(category_id: @recipe.category).order('name ASC')
  end

  def edit
    @page_title = 'Modifică rețeta - Cofetăria Irina - Bacău'
  end

  def update
    @recipe.update(recipe_params)
    if @recipe.update(recipe_params)
      redirect_to category_recipes_path(@category)
    else
      render :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to category_recipes_path(@category)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content, :photo, :kg_buc, :price_cents, :publish, :favored, :slug, :vegan, :energetic_value, :fats, :fatty_acids, :carbohydrates, :sugars, :proteins, :salt, :weight)
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_recipe
    @recipe = authorize Recipe.find_by(slug: params[:id])
  end
end
