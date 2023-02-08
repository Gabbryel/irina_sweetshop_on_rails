class RemoveRidFromModelComponents < ActiveRecord::Migration[6.1]
  def change
    remove_column :model_components, :rid, :integer
  end
end
