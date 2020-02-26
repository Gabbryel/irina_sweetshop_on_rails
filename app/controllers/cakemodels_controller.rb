class CakemodelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_category, only: %i[new create edit destroy]
  before_action :set_cakemodel, only: %i[ show edit update destroy]
  def new
    @cakemodel = Cakemodel.new
    authorize @cakemodel
  end

  def create
    @cakemodel = Cakemodel.new(cakemodel_params)
    @cakemodel.category = @category
    if @cakemodel.save
      redirect_to category_cakemodels_path(@category)
      else
        render :new
    end
    authorize @cakemodel
  end

  def index
    @cakemodels = policy_scope(Cakemodel).where(category_id: params[:category_id] )
  end
  
  def show
    @review = Review.new
  end

  def edit
  end
def update
  @cakemodel.update(cakemodel_params)
  if @cakemodel.update(cakemodel_params)
    redirect_to category_cakemodels_path(Cakemodel.find(params[:id]).category)
  else
    render :edit
  end
end

def destroy
  @cakemodel.destroy
  redirect_to category_cakemodels_path(@category)
end

  private

  def cakemodel_params
    params.require(:cakemodel).permit(:content, :photo)
  end

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find(params[:id])
    authorize @cakemodel
  end
end
