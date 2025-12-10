class OnlineOrdersController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    recipes_scope = policy_scope(Recipe)
                    .where(online_order: true, publish: true)
                    .includes(:category, photo_attachment: :blob)

    @categories_with_recipes = recipes_scope.group_by(&:category).sort_by do |category, _recipes|
      category&.name.to_s.downcase
    end

    @page_title = 'Comandă online - Cofetăria Irina - Bacău'
    @page_main_title = 'Comenzi online'
    @seo_keywords = recipes_scope.map(&:name).join(', ')
  end
end
