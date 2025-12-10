module Shop
  class CartsController < BaseController
    def show
      prepare_delivery_context
      respond_to do |format|
        format.html
        format.json { render json: cart_payload }
      end
    end

    private

    def prepare_delivery_context
      @county_options = Cart::COUNTIES
      @delivery_methods = Cart::DELIVERY_METHODS
      @delivery_window = @cart.delivery_window
      @delivery_min_date = @delivery_window.min_date
      @delivery_max_date = @delivery_window.max_date
      @disabled_delivery_dates = @delivery_window.blocked_dates.map(&:iso8601)
      @pickup_only = @cart.requires_pickup_only?
    end
  end
end
