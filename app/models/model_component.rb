class ModelComponent < ApplicationRecord
  belongs_to :cakemodel
  belongs_to :recipe
  # after_save :set_recipe_dependant, unless: :verify_recipe

  # self.ignored_columns = ["recipe_id"]

end
