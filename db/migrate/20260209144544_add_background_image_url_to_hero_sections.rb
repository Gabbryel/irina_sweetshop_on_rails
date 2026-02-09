class AddBackgroundImageUrlToHeroSections < ActiveRecord::Migration[7.0]
  def change
    add_column :hero_sections, :background_image_url, :string
  end
end
