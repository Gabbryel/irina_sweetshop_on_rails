class AddNameToCakemodels < ActiveRecord::Migration[6.0]
  def change
    add_column :cakemodels, :name, :string
  end
end
