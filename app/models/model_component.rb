class ModelComponent < ApplicationRecord
  belongs_to :cakemodel
  belongs_to :recipe

  # self.ignored_columns = ["recipe_id"]

end
