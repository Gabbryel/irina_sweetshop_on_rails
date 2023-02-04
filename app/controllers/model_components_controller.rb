class ModelComponentsController < ApplicationController
  before_action :set_cakemodel, only: %i[new create destroy]
  before_action :set_cake_component, only: %i[destroy]

  def new
    @model_component = authorize ModelComponent.new()
  end

  def create
    @model_component = authorize ModelComponent.create(model_components_params)
    @model_component.cakemodel = @cakemodel
    if @model_component.save!
      redirect_to cakemodel_path(@cakemodel)
    end
  end

  def destroy
    if @model_component.destroy
      redirect_to cakemodel_path(@cakemodel)
    end
  end

  private

  def model_components_params
    params.require(:model_component).permit(:weight, :rid, :cakemodel_id, :recipe_name, :recipe_price)
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find_by(slug: params[:cakemodel_id])
  end
end
