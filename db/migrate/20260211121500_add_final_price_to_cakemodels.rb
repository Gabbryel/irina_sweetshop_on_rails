class AddFinalPriceToCakemodels < ActiveRecord::Migration[6.0]
  def change
    add_column :cakemodels, :final_price, :decimal, precision: 10, scale: 2
  end
end
