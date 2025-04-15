class RecipesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show search]
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
    # @page_title = "Rețete de #{ @category.name.downcase }"
    @recipe = authorize Recipe.new
  end

  def search
    skip_authorization
    if params[:search].present?
      @pagy, @recipes = pagy(policy_scope(Recipe).where("name ILIKE ?", "%#{params[:search][:search_for]}%").order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
    end
  end

  def admin_recipes

    if params[:search].nil?
      @pagy, @recipes = pagy(policy_scope(Recipe).order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
    else
      if params[:search][:favored].present?
        @pagy, @recipes = pagy(policy_scope(Recipe).where(favored: params[:search][:favored]).order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
      elsif params[:search][:search_for].present?
        @pagy, @recipes = pagy(policy_scope(Recipe).where("name ILIKE ?", "%#{params[:search][:search_for]}%").order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
      end
    end
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
        page = (@recipes.index(@recipe.slug) / Pagy::DEFAULT[:items]).next
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
    if @recipe.destroy
      respond_to do |format|
        format.html { redirect_to category_recipes_path(@category), notice: "Ai șters cu succes!" }
      end
    else
      redirect_to recipe_path(@recipe), notice: "Se pare că această specialitate medicală are extra-vieți! Mai încearcă încă o dată ștergerea!"
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:name, :content, :photo, :kg_buc, :price_cents, :publish, :favored, :position, :slug, :vegan, :energetic_value, :fats, :fatty_acids, :carbohydrates, :sugars, :proteins, :salt, :weight, :ingredients)
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_recipe
    @recipe = authorize Recipe.find_by(slug: params[:id])
  end
end
