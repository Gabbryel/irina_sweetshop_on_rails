class CreateHeroSections < ActiveRecord::Migration[7.0]
  def change
    create_table :hero_sections do |t|
      t.string :title
      t.string :subtitle
      t.string :background_image
      t.string :main_image

      t.timestamps
    end
  end
end
