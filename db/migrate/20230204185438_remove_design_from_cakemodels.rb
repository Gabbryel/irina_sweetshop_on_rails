class RemoveDesignFromCakemodels < ActiveRecord::Migration[6.1]
  def change
    remove_column :cakemodels, :design, :string
  end
end
