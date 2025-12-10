class AddWeightOrderingFieldsToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :can_be_ordered_by_kg, :boolean, default: false, null: false
    add_column :recipes, :minimal_order, :decimal, precision: 5, scale: 2
  end
end
