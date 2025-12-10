class AddDisableDeliveryForDaysToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :disable_delivery_for_days, :integer, null: false, default: 0
  end
end
