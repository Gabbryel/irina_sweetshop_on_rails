require 'bigdecimal'

class UpdateRecipePricingFields < ActiveRecord::Migration[7.0]
  class Recipe < ActiveRecord::Base
    self.table_name = 'recipes'
  end

  def up
    add_column :recipes, :sell_by_piece, :boolean, default: false, null: false
    add_column :recipes, :online_selling_price_cents, :integer, default: 0, null: false

    say_with_time 'Backfilling sell_by_piece and online_selling_price_cents' do
      Recipe.reset_column_information
      Recipe.find_each do |recipe|
        sells_by_piece = recipe.kg_buc.to_s.downcase == 'buc'
        quantity = compute_quantity(recipe, sells_by_piece)
        price_cents = recipe.price_cents.to_i
        online_price = (BigDecimal(price_cents.to_s) * BigDecimal(quantity.to_s)).round(0).to_i

        recipe.update_columns(
          sell_by_piece: sells_by_piece,
          online_selling_price_cents: online_price.positive? ? online_price : 0
        )
      end
    end

    remove_column :recipes, :piece_price_cents, :integer
    remove_column :recipes, :can_be_ordered_by_kg, :boolean
  end

  def down
    add_column :recipes, :piece_price_cents, :integer
    add_column :recipes, :can_be_ordered_by_kg, :boolean, default: false, null: false

    say_with_time 'Restoring piece_price_cents defaults' do
      Recipe.reset_column_information
      Recipe.find_each do |recipe|
        recipe.update_columns(piece_price_cents: recipe.price_cents)
      end
    end

    remove_column :recipes, :sell_by_piece, :boolean
    remove_column :recipes, :online_selling_price_cents, :integer
  end

  private

  def compute_quantity(recipe, sells_by_piece)
    if sells_by_piece
      recipe.weight.to_f.positive? ? recipe.weight.to_f : 1.0
    else
      kg_value = recipe.kg_buc.to_s.tr(',', '.').to_f
      kg_value = recipe.minimal_order.to_f if kg_value <= 0 && recipe.minimal_order.to_f.positive?
      kg_value.positive? ? kg_value : 1.0
    end
  end
end
