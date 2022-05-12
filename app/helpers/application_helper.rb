module ApplicationHelper
  def card_recipe_description(text)
    text.split(' ').first(7).join(' ')
  end
end
