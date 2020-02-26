class CreateCakemodels < ActiveRecord::Migration[6.0]
  def change
    create_table :cakemodels do |t|
      t.text :content
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
