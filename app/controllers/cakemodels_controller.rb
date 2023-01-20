class CakemodelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_category, only: %i[new create edit destroy index show]
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
      redirect_to category_cakemodels_path(@category)
      else
        render :new
    end
  end

  def index
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category )
    @page_title = "Modele de #{ @category.name.downcase } || Cofetăria Irina - Bacau"
  end
  
  def show
    @review = Review.new
    @reviews =  @cakemodel.reviews.all.order('id DESC')
    @category = Category.find(@cakemodel.category_id)
    @page_title = "Detalii și recenzii pentru #{ @cakemodel.content } "
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category).order('id ASC')
  end

  def edit
    @page_title = 'Modifică sugestie de prezentare || Cofetăria Irina Bacău'
  end
def update
  @cakemodel.update(cakemodel_params)
  if @cakemodel.update(cakemodel_params)
    redirect_to category_cakemodels_path(Category.find(@category))
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
    params.require(:cakemodel).permit(:name, :content, :photo)
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_cakemodel
    @cakemodel = Cakemodel.find_by(slug: params[:id])
    authorize @cakemodel
  end
end
