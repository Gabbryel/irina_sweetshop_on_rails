class AddChocolateColorToHeroSections < ActiveRecord::Migration[7.0]
  def change
    add_column :hero_sections, :chocolate_color, :string
  end
end
