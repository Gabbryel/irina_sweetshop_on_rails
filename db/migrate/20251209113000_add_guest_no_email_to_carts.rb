class AddGuestNoEmailToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :guest_no_email, :boolean, default: false, null: false
    add_index :carts, :guest_no_email
  end
end
