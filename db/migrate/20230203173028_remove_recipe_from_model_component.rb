class RemoveRecipeFromModelComponent < ActiveRecord::Migration[6.1]
  def change
    remove_column :model_components, :recipe, :string
  end
end
