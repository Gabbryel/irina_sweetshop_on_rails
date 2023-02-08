class AddWeightToCakemodels < ActiveRecord::Migration[6.1]
  def change
    add_column :cakemodels, :weight, :float, null: true
  end
end
