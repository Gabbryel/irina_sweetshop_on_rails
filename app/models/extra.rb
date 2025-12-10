class Extra < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true

  monetize :price_cents

  scope :available, -> { where(available: true) }
end
