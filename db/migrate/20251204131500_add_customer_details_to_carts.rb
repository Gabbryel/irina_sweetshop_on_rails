class AddCustomerDetailsToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :customer_full_name, :string
    add_column :carts, :customer_phone, :string
    add_column :carts, :delivery_address, :text
    add_column :carts, :customer_notes, :text
  end
end
