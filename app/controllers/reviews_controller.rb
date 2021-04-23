class ReviewsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :set_review_target, only: [:edit]
  
  def create
    @review = authorize Review.new(review_params)
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
      @review.reviewable = @recipe
    elsif params[:cakemodel_id]
      @cakemodel = Cakemodel.find(params[:cakemodel_id])
      @review.reviewable = @cakemodel
    end
    @review.user = current_user
      if @review.save
        if @recipe
          redirect_to recipe_path(@recipe)
        elsif @cakemodel
          redirect_to cakemodel_path(@cakemodel)
        end
      else
        if @recipe
          redirect_to recipe_path(@recipe), notice: "Recenzia nu a fost salvată! Completați atât ratingul, cât și textul recenziei. Vă mulțumim!"
        elsif @cakemodel
          redirect_to cakemodel_path(@cakemodel), notice: "Recenzia nu a fost salvată! Completați atât ratingul, cât și textul recenziei. Vă mulțumim!"
        end
      end
  end

  def edit
  end

  def update
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
      if @review.update(review_params)
        redirect_to recipe_path(@recipe)
      end
    elsif params[:cakemodel_id]
      @cakemodel = Cakemodel.find(params[:cakemodel_id])
      if @review.update(review_params)
        redirect_to cakemodel_path(@cakemodel)
      end
    end
  end

  def destroy
    @review.destroy
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
      redirect_to recipe_path(@recipe)
    elsif params[:cakemodel_id]
      @cakemodel = Cakemodel.find(params[:cakemodel_id])
      redirect_to cakemodel_path(@cakemodel)
    end
  end

  private

  def set_review
    @review = authorize Review.find(params[:id])
  end

  def set_review_target
    if params[:recipe_id]
      @recipe = Recipe.find(params[:recipe_id])
    elsif params[:cakemodel_id]
      @cakemodel = Cakemodel.find(params[:cakemodel_id])
    end
  end

  def review_params
    params.require(:review).permit(:rating, :content, :approved)
  end
end