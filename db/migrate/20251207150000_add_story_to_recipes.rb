class AddStoryToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :story, :text
  end
end
