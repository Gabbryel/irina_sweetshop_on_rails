class AddRecipeReferenceToItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :items, :recipe, foreign_key: true
  end
end
