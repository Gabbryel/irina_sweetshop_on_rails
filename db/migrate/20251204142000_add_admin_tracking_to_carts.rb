class AddAdminTrackingToCarts < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :admin_notes, :text
    add_column :carts, :fulfilled_at, :datetime
    add_column :carts, :cancelled_at, :datetime
  end
end
