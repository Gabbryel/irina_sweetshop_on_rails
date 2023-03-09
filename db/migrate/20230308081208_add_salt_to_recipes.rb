class AddSaltToRecipes < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :salt, :float
  end
end
