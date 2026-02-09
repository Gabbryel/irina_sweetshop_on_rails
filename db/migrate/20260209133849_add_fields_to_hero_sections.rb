class AddFieldsToHeroSections < ActiveRecord::Migration[7.0]
  def change
    add_column :hero_sections, :button_text, :string
    add_column :hero_sections, :button_link, :string
  end
end
