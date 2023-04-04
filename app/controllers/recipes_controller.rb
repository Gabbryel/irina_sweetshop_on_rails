class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_category
  before_action :set_recipe, only: %i[show edit update destroy]
  
  def new
    @recipe = authorize Recipe.new
    @page_title = "Rețetă nouă de #{@category.name.downcase}- Cofetăria Irina - Bacău"
  end

  def create
    @recipe = authorize Recipe.new(recipe_params)
    @recipe.category = @category
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to retete_path(anchor: @recipe.slug, notice: 'Rețetă adaugată') }
        format.json { render :show, status: created, location: @recipe}
      else
        format.turbo_stream
        format.html { render :new }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
  end
end
  
  def index
    @recipes = policy_scope(Recipe).where(category_id: @category, publish: true).order('name ASC').includes([{photo_attachment: :blob}, :reviews])
    @page_title = "Rețete de #{ @category.name.downcase }"
    @recipe = authorize Recipe.new
  end

  def admin_recipes
    @pagy, @recipes = pagy(policy_scope(Recipe).order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
    @recipe = authorize Recipe.new

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
    @recipe = @recipe.nil? ? Recipe.find_by(slug: params[:recipe][:id]) : @recipe
    @category = @category.nil? ? Category.find_by(slug: params[:recipe][:category_id]) : @category
    @page_title = 'Modifică rețeta - Cofetăria Irina - Bacău'
  end

  def update
    @recipes = Recipe.all.order(:slug).pluck(:slug)
    @recipe = @recipe.nil? ? Recipe.find_by(slug: params[:recipe][:id]) : @recipe
    @category = @category.nil? ? Category.find_by(slug: params[:recipe][:category_id]) : @category
    respond_to do |format|
      if @recipe.update(recipe_params)
        page = (@recipes.index(@recipe.slug) / Pagy::DEFAULT[:items]).ceil
        format.html { redirect_to retete_path(page: page, anchor: @recipe.slug, notice: 'Rețetă modificată') }
        format.json { render :show, status: :updated, location: @recipe }
      else
        format.turbo_stream
        format.html { render :edit }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipe.destroy
    redirect_to category_recipes_path(@category)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content, :photo, :kg_buc, :price_cents, :publish, :favored, :slug, :vegan, :energetic_value, :fats, :fatty_acids, :carbohydrates, :sugars, :proteins, :salt, :weight, :ingredients)
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_recipe
    @recipe = authorize Recipe.find_by(slug: params[:id])
  end
end
