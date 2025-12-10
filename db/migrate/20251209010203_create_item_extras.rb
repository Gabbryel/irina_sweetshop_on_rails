class CreateItemExtras < ActiveRecord::Migration[7.0]
  def change
    create_table :item_extras, if_not_exists: true do |t|
      t.references :item, null: false, foreign_key: true
      t.references :extra, foreign_key: true
      t.string :name, null: false
      t.integer :price_cents, default: 0, null: false

      t.timestamps
    end

    # `t.references` already creates indexes for foreign keys in recent Rails versions,
    # avoid adding a duplicate index which can cause PG::DuplicateTable errors.
  end
end
