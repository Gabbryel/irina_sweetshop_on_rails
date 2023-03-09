class AddFatsToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :fats, :float
  end
end
