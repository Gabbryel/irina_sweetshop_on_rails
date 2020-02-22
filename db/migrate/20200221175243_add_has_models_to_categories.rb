class AddHasModelsToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :has_models, :boolean
  end
end
