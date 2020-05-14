class Cart < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy

  def grand_total
    grand_total = []
    self.items.each do |i|
      grand_total << i.total
    end
    grand_total.sum()
  end
end
