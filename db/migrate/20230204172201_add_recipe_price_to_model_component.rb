class AddRecipePriceToModelComponent < ActiveRecord::Migration[6.1]
  def change
    add_column :model_components, :recipe_price, :float
  end
end
