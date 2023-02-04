class AddRidToModelComponent < ActiveRecord::Migration[6.1]
  def change
    add_column :model_components, :rid, :integer
  end
end
