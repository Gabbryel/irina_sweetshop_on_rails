class AddRecipeNameToModelComponent < ActiveRecord::Migration[6.1]
  def change
    add_column :model_components, :recipe_name, :string
  end
end
