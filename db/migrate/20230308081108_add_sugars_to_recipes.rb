class AddSugarsToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :sugars, :float
  end
end
