class AddEnergeticValueToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :energetic_value, :float
  end
end
