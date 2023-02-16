class AddVeganToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :vegan, :boolean
  end
end
