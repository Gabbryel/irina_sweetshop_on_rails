class CakemodelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_category, only: %i[new create edit update destroy index show]
  before_action :set_cakemodel, only: %i[show edit update destroy]
  before_action :load_form_dependencies, only: %i[new create edit update]

  def new
    @cakemodel = authorize Cakemodel.new
    @page_title = 'Sugestie de prezentare nouă || Cofetăria Irina Bacău'
  end

  def create
    @cakemodel = authorize Cakemodel.new(cakemodel_params)
    @cakemodel.category = @category

    selected_recipe = @torturi_recipes.find_by(id: @cakemodel.initial_recipe_id)
    unless selected_recipe
      @cakemodel.errors.add(:initial_recipe_id, 'trebuie sa fie din categoria Torturi')
      flash.now.alert = @cakemodel.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
      return
    end

    Cakemodel.transaction do
      @cakemodel.save!
      @cakemodel.model_components.create!(
        recipe: selected_recipe,
        weight: initial_component_weight(@cakemodel)
      )
    end

    redirect_to category_cakemodels_path(@category)
  rescue ActiveRecord::RecordInvalid => e
    flash.now.alert = if @cakemodel&.errors&.any?
                        @cakemodel.errors.full_messages.to_sentence
                      else
                        e.message
                      end
    render :new, status: :unprocessable_entity
  end

  def index
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category).order(:id)
    @page_title = "Modele de #{@category.name.downcase} || Cofetăria Irina - Bacau"
  end

  def show
    @review = Review.new
    @reviews = @cakemodel.reviews.all.order('id DESC')
    @category = @cakemodel.category
    @design = @cakemodel.design
    @page_title = "Detalii și recenzii pentru #{@cakemodel.name} "
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category).order('id ASC')
    @model_image = ModelImage.new
    @model_component = ModelComponent.new
    @recipes = torturi_recipes_scope
    @torturi_recipes = @recipes
  end

  def edit
    @page_title = 'Modifică sugestie de prezentare || Cofetăria Irina Bacău'
  end

  def update
    selected_recipe = selected_torturi_recipe_from_params
    if cakemodel_params[:initial_recipe_id].present? && selected_recipe.nil?
      @cakemodel.errors.add(:initial_recipe_id, 'trebuie sa fie din categoria Torturi')
      flash.now.alert = @cakemodel.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
      return
    end

    Cakemodel.transaction do
      @cakemodel.update!(cakemodel_params.except(:initial_recipe_id))
      sync_initial_recipe_component!(@cakemodel, selected_recipe) if selected_recipe.present?
    end

    redirect_to category_cakemodels_path(@category)
  rescue ActiveRecord::RecordInvalid
    flash.now.alert = @cakemodel.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @cakemodel.destroy
    redirect_to category_cakemodels_path(@category)
  end

  private

  def cakemodel_params
    params.require(:cakemodel).permit(
      :name,
      :photo,
      :design_id,
      :content,
      :featured_for_quick_order,
      :weight,
      :price_per_kg,
      :price_per_piece,
      :final_price,
      :available_online,
      :available_for_delivery,
      :initial_recipe_id
    )
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_cakemodel
    @cakemodel = authorize Cakemodel.find_by(slug: params[:id])
  end

  def load_form_dependencies
    @designs = Design.all
    @torturi_recipes = torturi_recipes_scope
    @recipe_price_map = build_recipe_price_map(@torturi_recipes)
    @design_price_map = build_design_price_map(@designs)
  end

  def initial_component_weight(cakemodel)
    grams = cakemodel.weight.to_f
    return 0.0 if grams <= 0

    (grams / 1000.0).round(3)
  end

  def torturi_recipes_scope
    torturi_category = Category.where("LOWER(TRIM(slug)) = :name OR LOWER(TRIM(name)) = :name", name: 'torturi').first
    return Recipe.none unless torturi_category

    Recipe.where(category_id: torturi_category.id).order(:name)
  end

  def build_recipe_price_map(recipes)
    recipes.each_with_object({}) do |recipe, map|
      map[recipe.id] = money_to_float(recipe.price)
    end
  end

  def build_design_price_map(designs)
    designs.each_with_object({}) do |design, map|
      map[design.id] = money_to_float(design.price)
    end
  end

  def money_to_float(value)
    return 0.0 if value.blank?
    return value.to_d.to_f.round(2) if value.respond_to?(:to_d)

    value.to_f.round(2)
  rescue StandardError
    0.0
  end

  def selected_torturi_recipe_from_params
    selected_id = cakemodel_params[:initial_recipe_id].presence
    return nil if selected_id.blank?

    torturi_recipes_scope.find_by(id: selected_id)
  end

  def sync_initial_recipe_component!(cakemodel, recipe)
    component = cakemodel.model_components.order(:id).first || cakemodel.model_components.new
    component.recipe = recipe

    if component.new_record? || component.weight.blank? || component.weight.to_f <= 0
      component.weight = initial_component_weight(cakemodel)
    end

    component.save! if component.changed?
  end
end
