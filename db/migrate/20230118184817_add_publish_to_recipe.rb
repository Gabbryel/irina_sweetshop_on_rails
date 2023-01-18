class AddPublishToRecipe < ActiveRecord::Migration[6.1]
  def change
    add_column :recipes, :publish, :boolean, default: false
  end
end
