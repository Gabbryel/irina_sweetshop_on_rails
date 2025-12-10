class AddDeliveryFieldsToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :county, :string
    add_column :carts, :delivery_date, :date
    add_column :carts, :method_of_delivery, :string
  end
end
