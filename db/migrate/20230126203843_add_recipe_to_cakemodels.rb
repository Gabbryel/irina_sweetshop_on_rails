class AddRecipeToCakemodels < ActiveRecord::Migration[6.1]
  def change
    add_reference :cakemodels, :recipe, null: true, foreign_key: true
  end
end
