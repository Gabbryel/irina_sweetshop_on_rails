class CakemodelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_category, only: %i[new create edit destroy]
  before_action :set_cakemodel, only: %i[ show edit update destroy]
  def new
    @cakemodel = Cakemodel.new
    authorize @cakemodel
    @page_title = 'Sugestie de prezentare nouă || Cofetăria Irina Bacău'
  end

  def create
    @cakemodel = authorize Cakemodel.new(cakemodel_params)
    @cakemodel.category = @category
    if @cakemodel.save
      redirect_to category_path(@category)
      else
        render :new
    end
  end

  def index
    @cakemodels = policy_scope(Cakemodel).where(category_id: params[:category_id] )
    @page_title = "Modele de #{ Category.find(params[:category_id]).name.downcase } || Cofetăria Irina - Bacau"
  end
  
  def show
    @review = Review.new
    @reviews =  @cakemodel.reviews.all
    @page_title = "Detalii și recenzii pentru #{ Cakemodel.find(params[:id]).content } "
  end

  def edit
    @page_title = 'Modifică sugestie de prezentare || Cofetăria Irina Bacău'
  end
def update
  @cakemodel.update(cakemodel_params)
  if @cakemodel.update(cakemodel_params)
    redirect_to category_path(Category.find(params[:category_id]))
  else
    render :edit
  end
end

def destroy
  @cakemodel.destroy
  redirect_to category_path(@category)
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
