class CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def new
    @category = Category.new
    authorize @category
    @page_title = 'Creează o nouă categorie || Cofetăria Irina - Bacău'
  end

  def create
   @category = Category.new(category_params)
   authorize @category
   if @category.save
    redirect_to categories_path, notice: 'Category was successfully created.'
   else
    render :new
   end
  end

  def index
    @categories = policy_scope(Category).order('id ASC')
    @page_title = 'Categorii de produse || Cofetăria Irina - Bacau'
  end

  def show
    @recipes = @category.recipes
    @cakemodels = @category.cakemodels
    @page_title = "Rețete de #{@category.name.downcase} ・ Cofetăria Irina"
    @page_main_title = @category.name
  end

  def edit
    @page_title = 'Modifică categoria || Cofetăria Irina - Bacău'
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :photo, :has_recipe, :has_models)
  end

  def set_category
    @category = authorize Category.find(params[:id])
  end

end
