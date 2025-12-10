class CreateExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :extras do |t|
      t.references :recipe, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :price_cents, default: 0, null: false
      t.boolean :available, default: true, null: false
      t.integer :position

      t.timestamps
    end

    add_index :extras, [:recipe_id, :position]
  end
end
