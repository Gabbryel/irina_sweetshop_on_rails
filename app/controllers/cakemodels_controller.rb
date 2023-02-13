class CakemodelsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_category, only: %i[new create edit update destroy index show]
  before_action :set_cakemodel, only: %i[ show edit update destroy]
  def new
    @cakemodel = authorize Cakemodel.new
    @designs = Design.all
    @page_title = 'Sugestie de prezentare nouă || Cofetăria Irina Bacău'
  end

  def create
    @cakemodel = authorize Cakemodel.new(cakemodel_params)
    @designs = Design.all
    @cakemodel.category = @category
    @cakemodel.design = Design.find(params[:cakemodel][:design_id])
    if @cakemodel.save!
      redirect_to category_cakemodels_path(@category)
      else
        render :new
        flash.alert = 'Ceva nu a mers...'
    end
  end

  def index
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category )
    @page_title = "Modele de #{ @category.name.downcase } || Cofetăria Irina - Bacau"
  end
  
  def show
    @review = Review.new
    @reviews =  @cakemodel.reviews.all.order('id DESC')
    @category = @cakemodel.category
    @design = @cakemodel.design
    @page_title = "Detalii și recenzii pentru #{ @cakemodel.name } "
    @cakemodels = policy_scope(Cakemodel).where(category_id: @category).order('id ASC')
    @model_image = ModelImage.new()
    @model_component = ModelComponent.new()
    @recipes = Recipe.all.order(name: :asc)
  end

  def edit
    @page_title = 'Modifică sugestie de prezentare || Cofetăria Irina Bacău'
    @designs = Design.all
  end
def update
  @cakemodel.update(cakemodel_params)
  if @cakemodel.update(cakemodel_params)
    redirect_to category_cakemodels_path(@category)
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
    params.require(:cakemodel).permit(:name, :photo, :design_id, :content)
  end

  def set_category
    @category = Category.find_by(slug: params[:category_id])
  end

  def set_cakemodel
    @cakemodel = authorize Cakemodel.find_by(slug: params[:id])
  end
end
