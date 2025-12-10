class SetNoStatusDefaultOnCarts < ActiveRecord::Migration[7.0]
  def up
    change_column_default :carts, :status, from: "seen", to: "no_status"

    execute <<~SQL
      UPDATE carts
      SET status = 'no_status'
      WHERE status IS NULL OR status = '';
    SQL
  end

  def down
    change_column_default :carts, :status, from: "no_status", to: "seen"
  end
end
