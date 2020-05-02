class AddKgToRecipes < ActiveRecord::Migration[6.0]
  def change
    add_column :recipes, :kg, :boolean
  end
end
