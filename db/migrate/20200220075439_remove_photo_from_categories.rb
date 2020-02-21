class RemovePhotoFromCategories < ActiveRecord::Migration[6.0]
  def change

    remove_column :categories, :photo, :string
  end
end
