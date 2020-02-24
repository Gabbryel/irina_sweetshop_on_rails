class RemoveRecipeFromReviews < ActiveRecord::Migration[6.0]
  def change
    remove_reference :reviews, :recipe, null: false, foreign_key: true
  end
end
