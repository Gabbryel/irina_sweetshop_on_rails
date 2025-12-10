class AddPiecePriceToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :piece_price_cents, :integer

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE recipes
          SET piece_price_cents = price_cents
          WHERE LOWER(COALESCE(kg_buc, '')) = 'buc';
        SQL
      end
    end
  end
end
