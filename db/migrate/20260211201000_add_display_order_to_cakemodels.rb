class AddDisplayOrderToCakemodels < ActiveRecord::Migration[7.0]
  def change
    return if column_exists?(:cakemodels, :display_order)

    add_column :cakemodels, :display_order, :integer, default: 0, null: false
    add_index :cakemodels, :display_order
  end
end
