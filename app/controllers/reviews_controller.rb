class ReviewsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  

  def new
    @recipe = Recipe.find(params[:recipe_id])
    @review = Review.new
  end

  def create
    @recipe = Recipe.find(params[:recipe_id])
    @review = Review.new(review_params)
    @review.recipe = @recipe
      if @review.save
        redirect_to category_recipes_path(params[:category_id])
      else
        render :new
      end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end