class RemoveRecipeFromCakemodels < ActiveRecord::Migration[6.1]
  def change
    remove_column :cakemodels, :recipe_id
  end
end