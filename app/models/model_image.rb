class ModelImage < ApplicationRecord
  has_one_attached :photo
  belongs_to :cakemodel
end
