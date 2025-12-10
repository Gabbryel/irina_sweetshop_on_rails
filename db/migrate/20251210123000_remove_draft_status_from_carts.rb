class RemoveDraftStatusFromCarts < ActiveRecord::Migration[7.0]
  def up
    # Update existing draft statuses to the new starting status
    execute <<~SQL
      UPDATE carts SET status = 'seen' WHERE status = 'draft';
    SQL

    change_column_default :carts, :status, from: 'draft', to: 'seen'
  end

  def down
    change_column_default :carts, :status, from: 'seen', to: 'draft'
    execute <<~SQL
      UPDATE carts SET status = 'draft' WHERE status = 'seen';
    SQL
  end
end
