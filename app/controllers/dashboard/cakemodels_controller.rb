module Dashboard
  class CakemodelsController < ApplicationController
    before_action :authorize_admin_cakemodels!

    def index
      prepare_index
    end

    def create
      @cakemodel = Cakemodel.new(cakemodel_params)
      selected_recipe = torturi_recipes_scope.find_by(id: @cakemodel.initial_recipe_id)

      unless selected_recipe
        @cakemodel.errors.add(:initial_recipe_id, 'trebuie sa fie din categoria Torturi')
        flash.now.alert = @cakemodel.errors.full_messages.to_sentence
        prepare_index
        render :index, status: :unprocessable_entity
        return
      end

      Cakemodel.transaction do
        @cakemodel.save!
        @cakemodel.model_components.create!(
          recipe: selected_recipe,
          weight: initial_component_weight(@cakemodel)
        )
      end

      redirect_to dashboard_cakemodels_path(anchor: "cakemodel_#{@cakemodel.id}"), notice: 'Modelul a fost creat.'
    rescue ActiveRecord::RecordInvalid => e
      flash.now.alert = if @cakemodel&.errors&.any?
                          @cakemodel.errors.full_messages.to_sentence
                        else
                          e.message
                        end
      prepare_index
      render :index, status: :unprocessable_entity
    end

    def update
      @cakemodel = find_cakemodel_for_dashboard(params[:id])
      selected_recipe = selected_torturi_recipe_from_params

      if cakemodel_params[:initial_recipe_id].present? && selected_recipe.nil?
        @cakemodel.errors.add(:initial_recipe_id, 'trebuie sa fie din categoria Torturi')
        flash.now.alert = @cakemodel.errors.full_messages.to_sentence
        @edit_cakemodel_id = @cakemodel.id
        prepare_index
        @cakemodels = @cakemodels.to_a.map { |cm| cm.id == @cakemodel.id ? @cakemodel : cm }
        render :index, status: :unprocessable_entity
        return
      end

      Cakemodel.transaction do
        @cakemodel.update!(cakemodel_params.except(:initial_recipe_id))
        sync_initial_recipe_component!(@cakemodel, selected_recipe) if selected_recipe.present?
      end

      redirect_to dashboard_cakemodels_path(anchor: "cakemodel_#{@cakemodel.id}"), notice: 'Modelul a fost actualizat.'
    rescue ActiveRecord::RecordInvalid
      flash.now.alert = @cakemodel.errors.full_messages.to_sentence
      @edit_cakemodel_id = @cakemodel.id
      prepare_index
      @cakemodels = @cakemodels.to_a.map { |cm| cm.id == @cakemodel.id ? @cakemodel : cm }
      render :index, status: :unprocessable_entity
    end

    private

    def authorize_admin_cakemodels!
      authorize Cakemodel, :admin_cakemodels?
    end

    def prepare_index
      @page_main_title = 'Administrare modele tort'
      @page_title = 'Administrare modele tort ・ Cofetăria Irina'
      @filters = extract_filters
      @categories = Category.order(:name)
      @designs = ::Design.order(:name)
      @torturi_recipes = torturi_recipes_scope
      @recipe_price_map = build_recipe_price_map(@torturi_recipes)
      @design_price_map = build_design_price_map(@designs)
      @selected_category = @filters[:category_id]
      @selected_design = @filters[:design_id]
      @cakemodel ||= Cakemodel.new

      base_scope = policy_scope(Cakemodel)
      @stats_cards = build_stats(base_scope)

      scoped = apply_filters(
        base_scope.includes(:category, :design, :model_components, { photo_attachment: :blob }).order(created_at: :desc)
      )

      @pagy, @cakemodels = pagy(scoped, items: 20)
      @current_scope_label = build_scope_label
    end

    def extract_filters
      permitted = params.fetch(:search, {}).permit(:search_for, :category_id, :design_id, :featured)

      filters = {}
      boolean_type = ActiveModel::Type::Boolean.new

      @search_query = permitted[:search_for].to_s.strip
      filters[:search_for] = @search_query if @search_query.present?

      if permitted[:category_id].present?
        category_id = permitted[:category_id].to_i
        filters[:category_id] = category_id if category_id.positive?
      end

      if permitted[:design_id].present?
        design_id = permitted[:design_id].to_i
        filters[:design_id] = design_id if design_id.positive?
      end

      filters[:featured] = true if permitted[:featured].present? && boolean_type.cast(permitted[:featured])

      filters
    end

    def apply_filters(scope)
      scoped = scope

      if @filters[:search_for].present?
        scoped = scoped.where('cakemodels.name ILIKE ?', "%#{@filters[:search_for]}%")
      end

      scoped = scoped.where(category_id: @filters[:category_id]) if @filters[:category_id]
      scoped = scoped.where(design_id: @filters[:design_id]) if @filters[:design_id]
      scoped = scoped.where(featured_for_quick_order: true) if @filters[:featured]

      scoped
    end

    def build_stats(scope)
      [
        { label: 'Modele totale', value: scope.count, icon: 'fa-solid fa-cake-candles', hint: 'Toate modelele create' },
        { label: 'Comandă rapidă', value: scope.where(featured_for_quick_order: true).count, icon: 'fa-solid fa-star', hint: 'Afișate pe homepage' },
        { label: 'Categorii active', value: scope.select(:category_id).distinct.count, icon: 'fa-solid fa-layer-group', hint: 'Categorii cu modele' },
        { label: 'Actualizate recent', value: scope.where('updated_at >= ?', 30.days.ago).count, icon: 'fa-solid fa-rotate', hint: 'Ultimele 30 de zile' }
      ]
    end

    def build_scope_label
      parts = []
      parts << (@filters[:search_for].present? ? "Căutare: \"#{@filters[:search_for]}\"" : 'Toate modelele')
      parts << "Categorie: #{Category.find(@filters[:category_id]).name}" if @filters[:category_id]
      parts << "Design: #{::Design.find(@filters[:design_id]).name}" if @filters[:design_id]
      parts << 'Doar pe homepage' if @filters[:featured]
      parts.join(' • ')
    rescue ActiveRecord::RecordNotFound
      'Toate modelele'
    end

    def cakemodel_params
      params.require(:cakemodel).permit(
        :name,
        :photo,
        :design_id,
        :category_id,
        :content,
        :featured_for_quick_order,
        :weight,
        :price_per_kg,
        :price_per_piece,
        :final_price,
        :available_online,
        :initial_recipe_id
      )
    end

    def torturi_recipes_scope
      torturi_category = Category.where("LOWER(TRIM(slug)) = :name OR LOWER(TRIM(name)) = :name", name: 'torturi').first
      return Recipe.none unless torturi_category

      Recipe.where(category_id: torturi_category.id).order(:name)
    end

    def initial_component_weight(cakemodel)
      grams = cakemodel.weight.to_f
      return 0.0 if grams <= 0

      (grams / 1000.0).round(3)
    end

    def build_recipe_price_map(recipes)
      recipes.each_with_object({}) do |recipe, map|
        map[recipe.id] = money_to_float(recipe.price)
      end
    end

    def build_design_price_map(designs)
      designs.each_with_object({}) do |design, map|
        map[design.id] = money_to_float(design.price)
      end
    end

    def money_to_float(value)
      return 0.0 if value.blank?
      return value.to_d.to_f.round(2) if value.respond_to?(:to_d)

      value.to_f.round(2)
    rescue StandardError
      0.0
    end

    def find_cakemodel_for_dashboard(identifier)
      Cakemodel.find_by(slug: identifier) || Cakemodel.find(identifier)
    rescue ActiveRecord::RecordNotFound
      Cakemodel.find_by!(slug: identifier)
    end

    def selected_torturi_recipe_from_params
      selected_id = cakemodel_params[:initial_recipe_id].presence
      return nil if selected_id.blank?

      torturi_recipes_scope.find_by(id: selected_id)
    end

    def sync_initial_recipe_component!(cakemodel, recipe)
      component = cakemodel.model_components.order(:id).first || cakemodel.model_components.new
      component.recipe = recipe

      if component.new_record? || component.weight.blank? || component.weight.to_f <= 0
        component.weight = initial_component_weight(cakemodel)
      end

      component.save! if component.changed?
    end
  end
end
