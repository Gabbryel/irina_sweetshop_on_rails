class AddKgBucToRecipes < ActiveRecord::Migration[6.0]
  def change
    add_column :recipes, :kg_buc, :string
  end
end
