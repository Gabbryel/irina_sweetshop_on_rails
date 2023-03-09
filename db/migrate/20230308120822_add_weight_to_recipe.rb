class AddWeightToRecipe < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :weight, :float, default: 0
  end
end
