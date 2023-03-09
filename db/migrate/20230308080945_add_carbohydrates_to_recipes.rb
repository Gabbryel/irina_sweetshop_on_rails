class AddCarbohydratesToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :carbohydrates, :float
  end
end
