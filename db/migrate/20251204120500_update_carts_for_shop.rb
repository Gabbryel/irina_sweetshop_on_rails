class UpdateCartsForShop < ActiveRecord::Migration[7.0]
  def change
    change_column_null :carts, :user_id, true
    add_column :carts, :guest_token, :string
    add_column :carts, :status, :string, null: false, default: "draft"
    add_column :carts, :email, :string
    add_column :carts, :stripe_checkout_session_id, :string
    add_column :carts, :stripe_payment_intent_id, :string
    add_index :carts, :guest_token, unique: true
    add_index :carts, :status
  end
end
