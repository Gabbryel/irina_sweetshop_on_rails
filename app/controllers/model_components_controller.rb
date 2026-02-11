class ModelComponentsController < ApplicationController
  before_action :set_cakemodel, only: %i[new create destroy]

  def new
    @model_component = authorize ModelComponent.new()
  end

  def create
    @model_component = authorize ModelComponent.new(model_components_params.except(:recipe_id))
    @model_component.cakemodel = @cakemodel
    selected_recipe = torturi_recipes_scope.find_by(id: params.dig(:model_component, :recipe_id))

    unless selected_recipe
      redirect_to cakemodel_path(@cakemodel), alert: 'Rețeta selectată trebuie să fie din categoria Torturi.'
      return
    end

    @model_component.recipe = selected_recipe

    if @model_component.save
      redirect_to cakemodel_path(@cakemodel), notice: 'Rețeta a fost adăugată!'
    else
      redirect_to cakemodel_path(@cakemodel), alert: 'Rețeta nu a fost salvată!'
    end
  end

  def destroy
    @model_component = authorize ModelComponent.find(params[:id])
    @model_component.destroy
    redirect_to cakemodel_path(@cakemodel)
  end

  private

  def model_components_params
    params.require(:model_component).permit(:weight, :recipe_id)
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find_by(slug: params[:cakemodel_id])
  end

  def torturi_recipes_scope
    torturi_category = Category.where("LOWER(TRIM(slug)) = :name OR LOWER(TRIM(name)) = :name", name: 'torturi').first
    return Recipe.none unless torturi_category

    Recipe.where(category_id: torturi_category.id)
  end
end
