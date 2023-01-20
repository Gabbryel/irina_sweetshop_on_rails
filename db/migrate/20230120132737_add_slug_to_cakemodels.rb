class AddSlugToCakemodels < ActiveRecord::Migration[6.1]
  def change
    add_column :cakemodels, :slug, :string
  end
end
