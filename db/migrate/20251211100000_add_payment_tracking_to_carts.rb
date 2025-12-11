class AddPaymentTrackingToCarts < ActiveRecord::Migration[6.0]
  def change
    add_column :carts, :paid_at, :datetime
    add_column :carts, :reminder_sent_at, :datetime
    add_column :carts, :payment_followups_scheduled_at, :datetime

    add_index :carts, :paid_at
    add_index :carts, :reminder_sent_at
    add_index :carts, :payment_followups_scheduled_at, name: "index_carts_on_payment_followups_scheduled_at"
  end
end
