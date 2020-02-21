class CategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def new
    @category = Category.new
    authorize @category
  end

  def create
   @category = Category.new(category_params)
   authorize @category
   if @category.save
    redirect_to categories_path, notice: 'Category was successfully created.'
   end
  end

  def index
    @categories = policy_scope(Category)
  end

  def show
  end

  def edit
  end

  def update
    @category.update(category_params)
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :photo)
  end

  def set_category
    @category = Category.find(params[:id])
    authorize @category
  end

end
