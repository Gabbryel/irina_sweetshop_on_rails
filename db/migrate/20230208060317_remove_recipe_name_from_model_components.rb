class RemoveRecipeNameFromModelComponents < ActiveRecord::Migration[6.1]
  def change
    remove_column :model_components, :recipe_name, :string
  end
end
