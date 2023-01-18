class AddFavoredToRecipe < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :favored, :boolean, default: false
  end
end
