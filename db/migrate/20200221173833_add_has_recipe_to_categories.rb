class AddHasRecipeToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :has_recipe, :boolean
  end
end
