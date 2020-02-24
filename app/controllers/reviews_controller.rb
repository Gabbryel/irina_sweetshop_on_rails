class ReviewsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  
  def create
    @recipe = Recipe.find(params[:recipe_id])
    @review = Review.new(review_params)
    @review.reviewable = @recipe
    @review.user = current_user
      if @review.save!
        redirect_to recipe_path(params[:recipe_id])
      else
        render 'recipes/show'
      end
      authorize @review
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end