class ModelImagesController < ApplicationController
  before_action :set_model_image, only: %i[destroy]
  before_action :set_cakemodel

  def new
    @model_image = authorize ModelImage.new()
  end

  def create
    @model_image = authorize ModelImage.create(model_images_params)
    @model_image.cakemodel = @cakemodel
    if @model_image.save
      redirect_to cakemodel_path(@cakemodel)
    else
      redirect_to cakemodel_path(@cakemodel)
      flash.alert = 'Nu am reușit!'
    end
  end

  def destroy
    if @model_image.destroy
      redirect_to cakemodel_path(@cakemodel)
    end
  end

  private

  def model_images_params
    params.require(:model_image).permit(:photo)
  end

  def set_model_image
    @model_image = authorize ModelImage.find(params[:id])
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find_by(slug: params[:cakemodel_id])
  end
end
