class AddDesignToCakemodels < ActiveRecord::Migration[6.1]
  def change
    add_column :cakemodels, :design, :string
  end
end
