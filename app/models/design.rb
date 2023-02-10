class Design < ApplicationRecord
  monetize :price_cents
  has_one :cakemodel, required: false
  belongs_to :category, optional: true
end
