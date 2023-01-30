class RemoveWeightFromCakemodels < ActiveRecord::Migration[6.1]
  def change
    remove_column :cakemodels, :weight
  end
end