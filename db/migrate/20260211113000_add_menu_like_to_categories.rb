class AddMenuLikeToCategories < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:categories, :menu_like)
      add_column :categories, :menu_like, :boolean, default: false, null: false
    end

    execute <<~SQL.squish
      UPDATE categories
      SET menu_like = TRUE
      WHERE LOWER(TRIM(COALESCE(slug, ''))) = 'torturi'
         OR LOWER(TRIM(COALESCE(name, ''))) = 'torturi'
    SQL
  end

  def down
    remove_column :categories, :menu_like if column_exists?(:categories, :menu_like)
  end
end
