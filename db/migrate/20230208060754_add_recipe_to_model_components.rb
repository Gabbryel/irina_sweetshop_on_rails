class AddRecipeToModelComponents < ActiveRecord::Migration[6.1]
  def change
    add_reference :model_components, :recipe, null: false, foreign_key: true
  end
end
