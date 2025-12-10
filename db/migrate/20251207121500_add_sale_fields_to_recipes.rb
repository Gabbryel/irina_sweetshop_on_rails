class AddSaleFieldsToRecipes < ActiveRecord::Migration[7.0]
  def up
    add_column :recipes, :sold_by, :string, null: false, default: 'kg'
    add_column :recipes, :online_selling_weight, :decimal, precision: 6, scale: 2

    execute <<-SQL.squish
      UPDATE recipes
      SET sold_by = CASE
        WHEN LOWER(COALESCE(kg_buc, '')) = 'buc' THEN 'buc'
        WHEN LOWER(COALESCE(kg_buc, '')) = 'kg' THEN 'kg'
        ELSE 'kg'
      END
    SQL
  end

  def down
    remove_column :recipes, :online_selling_weight
    remove_column :recipes, :sold_by
  end
end
