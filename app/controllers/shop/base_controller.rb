module Shop
  class BaseController < ApplicationController
    include CurrentCartConcern

    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_cart

    private

    def set_cart
      @cart = current_cart
    end

    def cart_payload(cart = current_cart)
      cart = cart.reload

      {
        id: cart.id,
        guest_token: cart.guest_token,
        status: cart.status,
        email: cart.email,
        customer_full_name: cart.customer_full_name,
        customer_phone: cart.customer_phone,
        delivery_address: cart.delivery_address,
        customer_notes: cart.customer_notes,
        total_cents: cart.total_cents,
        total: cart.total_money.format,
        county: cart.county,
        method_of_delivery: cart.method_of_delivery,
        delivery_date: cart.delivery_date&.iso8601,
        delivery_constraints: {
          earliest_date: cart.earliest_delivery_date.iso8601,
          disabled_dates: cart.delivery_blocked_dates.map(&:iso8601)
        },
        items: cart.items.map do |item|
          recipe = item.recipe
          {
            id: item.id,
            recipe_id: item.recipe_id,
            name: item.name,
            quantity: item.quantity,
            kg_buc: item.kg_buc,
            price_cents: item.price_cents,
            total_cents: item.total_cents,
            total: item.total_cents_money.format,
            unit_label: recipe&.sold_by.presence || recipe&.kg_buc.presence
          }
        end
      }
    end
  end
end
