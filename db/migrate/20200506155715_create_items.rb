class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.string :name
      t.float :quantity
      t.string :kg_buc

      t.timestamps
    end
  end
end
