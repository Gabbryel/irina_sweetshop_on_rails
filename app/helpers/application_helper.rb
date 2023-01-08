module ApplicationHelper
  def card_recipe_description(text)
    text.split(' ').first(5).join(' ')
  end
end
