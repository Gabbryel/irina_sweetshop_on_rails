class CreateModelComponents < ActiveRecord::Migration[6.1]
  def change
    create_table :model_components do |t|
      t.string :recipe
      t.float :weight
      t.references :cakemodel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
