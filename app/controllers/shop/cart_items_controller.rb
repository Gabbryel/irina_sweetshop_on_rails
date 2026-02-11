module Shop
  class CartItemsController < BaseController
    before_action :find_orderable, only: :create
    before_action :find_item, only: %i[update destroy]

    def create
      return if performed?

      @cart = ensure_cart!

      quantity = sanitized_quantity(default: default_quantity_for(@orderable))

      if @orderable.is_a?(Recipe)
        create_recipe_item(quantity)
      elsif @orderable.is_a?(Cakemodel)
        create_cakemodel_item(quantity)
      end

      @cart.schedule_payment_followups!

      render_cart_success(message: 'Produsul a fost adăugat în coș.')
    end

    def update
      return if performed?

      quantity = sanitized_quantity(allow_zero: true, default: 0.0)

      if quantity <= 0
        @item.destroy
      else
        quantity = normalize_quantity(@item.recipe || @item.cakemodel, quantity)
        @item.update!(quantity: quantity)
      end

      destroy_cart_if_empty!

      render_cart_success(message: 'Cantitatea a fost actualizată.')
    end

    def destroy
      return if performed?

      @item.destroy
      destroy_cart_if_empty!
      render_cart_success(message: 'Produsul a fost eliminat din coș.')
    end

    private

    def find_orderable
      recipe_identifier = params[:recipe_id] || params[:recipe_slug]
      cakemodel_identifier = params[:cakemodel_id] || params[:cakemodel_slug]

      if recipe_identifier.present?
        recipe_scope = Recipe.online_for_order
        recipe = recipe_scope.find_by(id: recipe_identifier) || recipe_scope.find_by(slug: recipe_identifier)

        if recipe&.supports_online_ordering?
          @orderable = recipe
          return
        end
      end

      if cakemodel_identifier.present?
        cakemodel_scope = Cakemodel.where(available_online: true)
        cakemodel = cakemodel_scope.find_by(id: cakemodel_identifier) || cakemodel_scope.find_by(slug: cakemodel_identifier)

        if cakemodel_available_for_order?(cakemodel)
          @orderable = cakemodel
          return
        end
      end

      message = 'Produsul nu este disponibil pentru comandă online.'
      respond_to do |format|
        format.json { render json: { error: message }, status: :unprocessable_entity }
        format.html { redirect_to shop_cart_path, alert: message }
      end
      nil
    end

    def find_item
      @item = @cart.items.includes(:recipe, :cakemodel).find(params[:id])
      return if item_available_for_order?(@item)

      message = 'Produsul nu mai este disponibil pentru comandă online.'
      @item.destroy

      respond_to do |format|
        format.json { render json: { error: message, cart: cart_payload }, status: :unprocessable_entity }
        format.html { redirect_to shop_cart_path, alert: message }
      end
    rescue ActiveRecord::RecordNotFound
      message = 'Produsul nu există în coș.'
      respond_to do |format|
        format.json { render json: { error: message, cart: cart_payload }, status: :not_found }
        format.html { redirect_to shop_cart_path, alert: message }
      end
    end

    def sanitized_quantity(allow_zero: false, default: 1.0)
      value = params.dig(:cart_item, :quantity)
      value = params[:quantity] if value.nil?
      numeric = if value.present?
                  value.to_s.tr(',', '.').to_f
                else
                  default
                end
      numeric = default if numeric <= 0 && !allow_zero
      numeric
    end

    def cart_payload
      cart = @cart
      cart = Cart.new unless cart&.persisted?
      super(cart)
    end

    def default_quantity_for(_orderable)
      1.0
    end

    def render_cart_success(message: nil)
      payload = cart_payload

      respond_to do |format|
        format.json { render json: payload, status: :ok }
        format.html { redirect_back fallback_location: shop_cart_path, notice: message }
      end
    end

    def destroy_cart_if_empty!
      return if @cart.blank?

      if @cart.items.reload.empty?
        @cart.destroy
        clear_cart_session!
        @cart = Cart.new
      end
    end

    def create_recipe_item(quantity)
      recipe = @orderable
      quantity_to_add = normalize_quantity(recipe, quantity)
      extra_ids = Array(params.dig(:cart_item, :extra_ids) || params[:cart_item]&.[](:extra_ids)).reject(&:blank?).map(&:to_i)

      item = if extra_ids.present?
               @cart.items.new(recipe: recipe)
             else
               @cart.items.find_or_initialize_by(recipe: recipe, cakemodel_id: nil)
             end

      item.user = current_user if current_user.present?
      item.name ||= recipe.name
      item.kg_buc = recipe.sold_by.presence || recipe.kg_buc.presence || 'buc'

      recipe_price = recipe.online_selling_price_cents.to_i
      item.price_cents = recipe_price.positive? ? recipe_price : recipe.price_cents
      item.quantity = (item.quantity || 0) + quantity_to_add
      item.save!

      return if extra_ids.blank?

      item.item_extras.destroy_all
      extras = Extra.where(id: extra_ids, recipe_id: recipe.id).available
      extras.each do |extra|
        item.item_extras.create!(extra: extra, name: extra.name, price_cents: extra.price_cents)
      end
      item.save!
    end

    def create_cakemodel_item(quantity)
      cakemodel = @orderable
      quantity_to_add = normalize_quantity(cakemodel, quantity)
      item = @cart.items.find_or_initialize_by(cakemodel: cakemodel, recipe_id: nil)

      item.user = current_user if current_user.present?
      item.name = cakemodel.name
      item.kg_buc = 'buc'
      item.price_cents = cakemodel_price_cents(cakemodel)
      item.quantity = (item.quantity || 0) + quantity_to_add
      item.save!
    end

    def normalize_quantity(orderable, quantity)
      quantity_value = quantity.to_f

      if orderable.is_a?(Recipe)
        unit = orderable.sold_by.presence || orderable.kg_buc.presence || 'buc'
        return quantity_value if unit.to_s.casecmp('kg').zero?
      end

      quantity_value.ceil
    end

    def item_available_for_order?(item)
      if item.recipe.present?
        return item.recipe.supports_online_ordering?
      end

      return cakemodel_available_for_order?(item.cakemodel) if item.cakemodel.present?

      false
    end

    def cakemodel_available_for_order?(cakemodel)
      cakemodel.present? && cakemodel.available_online? && cakemodel_price_cents(cakemodel).positive?
    end

    def cakemodel_price_cents(cakemodel)
      return 0 if cakemodel.blank?

      price = cakemodel.final_price.presence || cakemodel.price_per_piece
      (price.to_d * 100).round.to_i
    rescue StandardError
      0
    end
  end
end
