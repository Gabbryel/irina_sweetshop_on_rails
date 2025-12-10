class CreateDeliveryBlockDates < ActiveRecord::Migration[7.0]
  def change
    create_table :delivery_block_dates do |t|
      t.date :blocked_on, null: false
      t.string :reason
      t.timestamps
    end

    add_index :delivery_block_dates, :blocked_on, unique: true
  end
end
