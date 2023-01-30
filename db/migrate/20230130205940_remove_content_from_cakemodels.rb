class RemoveContentFromCakemodels < ActiveRecord::Migration[6.1]
  def change
    remove_column :cakemodels, :content
  end
end