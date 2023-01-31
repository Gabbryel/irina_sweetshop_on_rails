class AddPriceToDesigns < ActiveRecord::Migration[6.1]
  def change
    add_monetize :designs, :price, currency: {present: false}
  end
end
