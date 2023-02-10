class ModelComponentsController < ApplicationController
  before_action :set_cakemodel, only: %i[new create destroy]

  def new
    @model_component = authorize ModelComponent.new()
  end

  def create
    @model_component = authorize ModelComponent.create(model_components_params)
    @model_component.cakemodel = @cakemodel
    if @model_component.save
      @model_component.recipe = Recipe.find(params[:model_component][:recipe_id])
      @model_component.save
      redirect_to cakemodel_path(@cakemodel), notice: "Rețeta a fost adăugată!"
    else
      redirect_to cakemodel_path(@cakemodel), notice: "Rețeta nu a fost salvată!"
    end
  end

  def destroy
    @model_component = authorize ModelComponent.find(params[:id])
    if @model_component.destroy
      redirect_to cakemodel_path(@cakemodel)
    end
  end

  private

  def model_components_params
    params.require(:model_component).permit(:weight, :recipe_id)
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find_by(slug: params[:cakemodel_id])
  end
end
