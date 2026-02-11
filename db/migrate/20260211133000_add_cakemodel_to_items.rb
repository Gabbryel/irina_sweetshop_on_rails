class AddCakemodelToItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :items, :cakemodel, null: true, foreign_key: { on_delete: :nullify }, index: true
  end
end
