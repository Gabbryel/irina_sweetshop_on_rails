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
        format.html { redirect_to dashboard_recipes_path(anchor: @recipe.slug, notice: 'Rețetă adaugată') }
        format.json { render :show, status: created, location: @recipe }
      else
        format.turbo_stream
        format.html { render :new }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def index
    @recipes = policy_scope(Recipe)
               .where(category_id: @category, publish: true)
               .order('name ASC')
               .includes([{ photo_attachment: :blob }, :reviews])

    respond_to do |format|
      format.html do
        @recipe = authorize Recipe.new
      end

      format.json do
        render json: @recipes.as_json(
          only: %i[id name kg_buc price_cents weight online_selling_price_cents],
          include: {
            category: { only: %i[id name slug] }
          }
        ), status: :ok
      end
    end
  end

  def search
    skip_authorization
    if params[:search].present?
      @pagy, @recipes = pagy(policy_scope(Recipe).where("name ILIKE ?", "%#{params[:search][:search_for]}%").order(:slug).includes([:photo_attachment, :reviews]).includes([{photo_attachment: :blob}, :reviews, :category]))
    end
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
        format.html { redirect_to dashboard_recipes_path(page: page, anchor: @recipe.slug, notice: 'Rețetă modificată') }
        format.json { render :show, status: :updated, location: @recipe }
      else
        format.turbo_stream
        format.html { render :edit }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
    # binding.pry
  end

  def update_prices
    @categories = policy_scope(Category).order(:slug)
    @recipes_by_category = policy_scope(Recipe)
                  .includes(:category)
                  .order(:slug)
                  .group_by { |recipe| recipe.category_id.to_s }
    authorize Recipe
  end

  def bulk_update_prices
    authorize Recipe, :bulk_update_prices?

    updates = bulk_price_params
    updated_recipes = []
    errors = []

    Recipe.transaction do
      updates.each do |_key, attrs|
        attrs = attrs.to_h
        recipe_id = attrs['id'].presence || _key
        recipe = Recipe.find_by(id: recipe_id)
        next unless recipe

        assignable = extract_price_attributes(recipe, attrs)
        next if assignable.empty?

        unless recipe.update(assignable)
          errors << "#{recipe.name}: #{recipe.errors.full_messages.to_sentence}"
          next
        end

        updated_recipes << recipe.name
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    if errors.any?
      redirect_to preturi_path, alert: errors.join(' ')
    else
      message = if updated_recipes.any?
                  "Prețurile au fost actualizate pentru #{updated_recipes.size} rețet#{updated_recipes.size == 1 ? 'ă' : 'e'}."
                else
                  'Nu au fost detectate modificări.'
                end
      redirect_to preturi_path, notice: message
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
    params.require(:recipe).permit(
      :name, :content, :story, :photo, :kg_buc, :sold_by, :price_cents, :minimal_order,
      :online_selling_weight, :publish, :favored, :online_order, :position, :slug, :vegan,
      :energetic_value, :fats, :fatty_acids, :carbohydrates, :sugars, :proteins, :salt,
      :weight, :ingredients, :disable_delivery_for_days, :has_extras, :only_pickup,
      extras_attributes: %i[id name price_cents available position _destroy]
    )
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_recipe
    @recipe = authorize Recipe.find_by(slug: params[:id])
  end

  def bulk_price_params
    params.require(:recipes).transform_values do |recipe_params|
      recipe_params.permit(:id, :price_cents)
    end
  end

  def extract_price_attributes(recipe, attrs)
    assignable = {}

    return assignable unless attrs.key?('price_cents')

    price_value = attrs['price_cents'].to_s.strip
    if price_value.present? && price_value.to_i != recipe.price_cents.to_i
      assignable[:price_cents] = price_value
    end

    assignable
  end
end
