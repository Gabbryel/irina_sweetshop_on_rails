class Item < ApplicationRecord
  belongs_to :user
  belongs_to :cart

  monetize :price_cents

  def total
    self.price * self.quantity
  end
end
