class ReviewsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  
  def create
    @review = Review.new(review_params)
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
          redirect_to cakemodel_path(params[:cakemodel_id])
        end
      else
        if @recipe
          redirect_to recipe_path(@recipe), notice: "Recenzia nu a fost salvată! Completați atât ratingul, cât și textul recenziei. Vă mulțumim!"
        elsif @cakemodel
          redirect_to cakemodel_path(params[:cakemodel_id]), notice: "Recenzia nu a fost salvată! Completați atât ratingul, cât și textul recenziei. Vă mulțumim!"
        end
      end
      authorize @review
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end