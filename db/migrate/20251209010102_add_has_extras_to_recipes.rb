class AddHasExtrasToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :has_extras, :boolean, default: false, null: false
  end
end
