class RemoveKgFromRecipes < ActiveRecord::Migration[6.0]
  def change

    remove_column :recipes, :kg, :boolean
  end
end
