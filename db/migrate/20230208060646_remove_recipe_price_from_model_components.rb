class RemoveRecipePriceFromModelComponents < ActiveRecord::Migration[6.1]
  def change
    remove_column :model_components, :recipe_price, :float
  end
end
