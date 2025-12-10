class AddOnlineOrderToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :online_order, :boolean, default: false, null: false
  end
end
