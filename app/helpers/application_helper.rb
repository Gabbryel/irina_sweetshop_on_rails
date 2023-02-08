module ApplicationHelper
  def card_recipe_description(text)
    text.split(' ').first(5).join(' ')
  end
  def isUserAdmin?
    current_user && current_user.admin
  end
end
