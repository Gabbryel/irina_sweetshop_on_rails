class AddApprovedToReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :approved, :boolean, default: false
  end
end
