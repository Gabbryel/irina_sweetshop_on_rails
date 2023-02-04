class ModelComponent < ApplicationRecord
  belongs_to :cakemodel
  after_save :set_recipe_dependant, unless: :verify_recipe

  def recipe
    Recipe.find(self.rid)
  end

  def set_recipe_dependant
    self.recipe_name = recipe.name
    self.recipe_price = recipe.price
    self.save
  end

  def verify_recipe
    self.recipe_name == recipe.name
  end
end
