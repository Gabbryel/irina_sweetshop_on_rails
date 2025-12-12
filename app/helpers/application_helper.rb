module ApplicationHelper
  include Pagy::Frontend
  def card_recipe_description(text)
    text.split(' ').first(5).join(' ')
  end
  def isUserAdmin?
    current_user && current_user.admin
  end

  def cookie_consent_accepted?
    cookies[:cookie_consent] == 'accepted'
  end
end
