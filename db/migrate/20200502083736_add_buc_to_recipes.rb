class AddBucToRecipes < ActiveRecord::Migration[6.0]
  def change
    add_column :recipes, :buc, :boolean
  end
end
