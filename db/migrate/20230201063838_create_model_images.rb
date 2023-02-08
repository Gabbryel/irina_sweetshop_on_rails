class CreateModelImages < ActiveRecord::Migration[6.1]
  def change
    create_table :model_images do |t|

      t.timestamps
    end
  end
end
