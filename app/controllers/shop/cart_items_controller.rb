module Shop
  class CartItemsController < BaseController
    before_action :find_recipe, only: :create
    before_action :find_item, only: %i[update destroy]

    def create
      return if performed?

      @cart = ensure_cart!

      quantity = sanitized_quantity(default: default_quantity_for(@recipe))
      # support extras: if extras selected, create a distinct item record
      extra_ids = Array(params.dig(:cart_item, :extra_ids) || params[:cart_item]&.[](:extra_ids)).reject(&:blank?).map(&:to_i)

      if extra_ids.present?
        item = @cart.items.new(recipe: @recipe)
      else
        item = @cart.items.find_or_initialize_by(recipe: @recipe)
      end
      item.user = current_user if current_user.present?
      item.name ||= @recipe.name

      item.kg_buc = @recipe.sold_by.presence || @recipe.kg_buc.presence || 'buc'
      recipe_price = @recipe.online_selling_price_cents.to_i
      item.price_cents = recipe_price.positive? ? recipe_price : @recipe.price_cents

      new_quantity = (item.quantity || 0) + quantity

      item.quantity = new_quantity
      item.save!

      # attach extras if provided
      if extra_ids.present?
        # remove any placeholder extras for a fresh item
        item.item_extras.destroy_all
        extras = Extra.where(id: extra_ids, recipe_id: @recipe.id).available
        extras.each do |extra|
          item.item_extras.create!(extra: extra, name: extra.name, price_cents: extra.price_cents)
        end
        Rails.logger.info("[CartItems] Created #{item.item_extras.count} item_extras for item_id=#{item.id} extras=#{extra_ids.inspect}")
        # recalc totals after adding extras
        item.save!
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

    def find_recipe
      identifier = params[:recipe_id] || params[:recipe_slug]
      scope = Recipe.online_for_order
      @recipe = scope.find_by(id: identifier) || scope.find_by(slug: identifier)

      unless @recipe&.supports_online_ordering?
        message = 'Produsul nu este disponibil pentru comandă online.'
        respond_to do |format|
          format.json { render json: { error: message }, status: :unprocessable_entity }
          format.html { redirect_to shop_cart_path, alert: message }
        end
        return
      end
    end

    def find_item
      @item = @cart.items.includes(:recipe).find(params[:id])

      return if @item.recipe.present? && @item.recipe.supports_online_ordering?

      message = 'Produsul nu mai este disponibil pentru comandă online.'
      @item.destroy

      respond_to do |format|
        format.json { render json: { error: message, cart: cart_payload }, status: :unprocessable_entity }
        format.html { redirect_to shop_cart_path, alert: message }
      end

      nil
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
      super(@cart.reload)
    end

    def default_quantity_for(recipe)
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
  end
end
