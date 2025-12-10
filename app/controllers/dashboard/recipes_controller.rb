module Dashboard
  class RecipesController < ApplicationController
    before_action :authorize_admin_recipes!

    def index
      @page_main_title = 'Administrare rețete'
      @page_title = 'Administrare rețete ・ Cofetăria Irina'
      @filters = extract_filters
      @categories = Category.order(:name)
      @selected_category = @filters[:category_id]
      @online_filter = @filters.key?(:online_order) ? @filters[:online_order] : nil

      base_scope = policy_scope(Recipe)
      @stats_cards = build_stats(base_scope)

      scoped = apply_filters(
        base_scope.includes(:category, { photo_attachment: :blob }, :reviews).order(:slug)
      )

      @pagy, @recipes = pagy(scoped)
      @recipe = Recipe.new
      @current_scope_label = build_scope_label
    end

    private

    def authorize_admin_recipes!
      authorize Recipe, :admin_recipes?
    end

    def extract_filters
      permitted = params.fetch(:search, {}).permit(:favored, :search_for, :category_id, :online_order)

      filters = {}
      boolean_type = ActiveModel::Type::Boolean.new

      @search_query = permitted[:search_for].to_s.strip
      filters[:search_for] = @search_query if @search_query.present?

      filters[:favored] = true if permitted[:favored].present? && boolean_type.cast(permitted[:favored])

      if permitted[:category_id].present?
        category_id = permitted[:category_id].to_i
        filters[:category_id] = category_id if category_id.positive?
      end

      if permitted[:online_order].present?
        filters[:online_order] = boolean_type.cast(permitted[:online_order])
      end

      filters
    end

    def apply_filters(scope)
      scoped = scope

      if @filters[:search_for].present?
        scoped = scoped.where('recipes.name ILIKE ?', "%#{@filters[:search_for]}%")
      end

      scoped = scoped.where(favored: true) if @filters[:favored]
      scoped = scoped.where(category_id: @filters[:category_id]) if @filters[:category_id]

      if @filters.key?(:online_order)
        scoped = scoped.where(online_order: @filters[:online_order])
      end

      scoped
    end

    def build_stats(scope)
      [
        { label: 'Rețete totale', value: scope.count, icon: 'fa-solid fa-list-ul', hint: 'Toate înregistrările existente' },
        { label: 'Publicate', value: scope.where(publish: true).count, icon: 'fa-solid fa-bullhorn', hint: 'Vizibile pe site' },
        { label: 'Recomandate', value: scope.where(favored: true).count, icon: 'fa-solid fa-heart', hint: 'Marcate ca favorite' },
        { label: 'Actualizate recent', value: scope.where('updated_at >= ?', 30.days.ago).count, icon: 'fa-solid fa-rotate', hint: 'Ultimele 30 de zile' }
      ]
    end

    def build_scope_label
      return 'Toate rețetele' if @filters.blank?

      parts = []
      parts << 'Rețete recomandate' if @filters[:favored]
      parts << "Căutare: \"#{@filters[:search_for]}\"" if @filters[:search_for].present?

      if @selected_category
        category_name = @categories.find { |category| category.id == @selected_category }&.name
        parts << "Categoria: #{category_name}" if category_name.present?
      end

      if @filters.key?(:online_order)
        parts << (@filters[:online_order] ? 'Disponibile online' : 'Offline')
      end

      parts.compact!
      parts.empty? ? 'Toate rețetele' : parts.join(' · ')
    end
  end
end
