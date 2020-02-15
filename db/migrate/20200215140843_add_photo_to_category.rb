class AddPhotoToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :photo, :string
  end
end
