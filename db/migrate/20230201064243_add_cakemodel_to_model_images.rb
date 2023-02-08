class AddCakemodelToModelImages < ActiveRecord::Migration[6.1]
  def change
    add_reference :model_images, :cakemodel, null: true, foreign_key: true
  end
end
