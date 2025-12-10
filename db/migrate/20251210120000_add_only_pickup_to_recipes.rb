class AddOnlyPickupToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :only_pickup, :boolean, default: false, null: false
    add_index :recipes, :only_pickup
  end
end
