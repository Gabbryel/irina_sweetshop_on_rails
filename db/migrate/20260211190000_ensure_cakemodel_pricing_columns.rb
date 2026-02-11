class EnsureCakemodelPricingColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :cakemodels, :weight, :integer unless column_exists?(:cakemodels, :weight)
    add_column :cakemodels, :price_per_kg, :decimal, precision: 10, scale: 2 unless column_exists?(:cakemodels, :price_per_kg)
    add_column :cakemodels, :price_per_piece, :decimal, precision: 10, scale: 2 unless column_exists?(:cakemodels, :price_per_piece)
    add_column :cakemodels, :available_online, :boolean, default: false, null: false unless column_exists?(:cakemodels, :available_online)
    add_column :cakemodels, :final_price, :decimal, precision: 10, scale: 2 unless column_exists?(:cakemodels, :final_price)
  end
end
