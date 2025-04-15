class AddPositionToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :position, :integer, default: 9, null: true
  end
end
