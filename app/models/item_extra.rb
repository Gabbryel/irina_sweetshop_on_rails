class ItemExtra < ApplicationRecord
  belongs_to :item
  belongs_to :extra, optional: true

  monetize :price_cents

  validates :name, presence: true
end
