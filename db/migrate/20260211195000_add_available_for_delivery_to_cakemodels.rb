class AddAvailableForDeliveryToCakemodels < ActiveRecord::Migration[7.0]
  def change
    return if column_exists?(:cakemodels, :available_for_delivery)

    add_column :cakemodels, :available_for_delivery, :boolean, default: true, null: false
  end
end
