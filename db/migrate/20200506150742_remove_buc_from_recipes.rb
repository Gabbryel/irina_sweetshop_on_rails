class RemoveBucFromRecipes < ActiveRecord::Migration[6.0]
  def change

    remove_column :recipes, :buc, :boolean
  end
end
