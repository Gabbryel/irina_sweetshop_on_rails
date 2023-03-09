class AddFattyAcidsToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :fatty_acids, :float
  end
end
