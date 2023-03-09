class AddProteinsToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :proteins, :float
  end
end
