class AddTotalToItems < ActiveRecord::Migration[6.0]
  def change
    add_monetize :items, :total, currency: { present: false }
  end
end
