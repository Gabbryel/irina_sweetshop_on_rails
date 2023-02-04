class Design < ApplicationRecord
  monetize :price_cents
  has_one :cakemodel, required: false
end
