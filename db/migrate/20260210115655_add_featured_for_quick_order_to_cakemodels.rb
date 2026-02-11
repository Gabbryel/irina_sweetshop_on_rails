class AddFeaturedForQuickOrderToCakemodels < ActiveRecord::Migration[7.0]
  def change
    add_column :cakemodels, :featured_for_quick_order, :boolean, default: false
  end
end
