class AccountsController < ApplicationController
  def show
    @user = current_user
    authorize @user, :account?

    @display_name = @user.try(:name).presence || @user.email

    @page_title = 'Contul meu'
    @seo_keywords = 'cont, comenzi, irina sweetshop'

    @open_orders = current_user.carts.includes(:items).where(status: [
      Cart::STATUSES[:no_status],
      Cart::STATUSES[:seen],
      Cart::STATUSES[:in_production],
      Cart::STATUSES[:ready]
    ]).order(updated_at: :desc).limit(5)

    @past_orders = current_user.carts.includes(:items).where(status: [
      Cart::STATUSES[:delivered],
      Cart::STATUSES[:canceled],
      Cart::STATUSES[:refunded]
    ]).order(updated_at: :desc).limit(10)

    @orders_count = current_user.carts.count
    @delivered_count = current_user.carts.where(status: Cart::STATUSES[:delivered]).count
    @lifetime_spend = Money.new(Item.joins(:cart).where(carts: { user_id: current_user.id }).sum(:total_cents) || 0, Money.default_currency)
    @upcoming_delivery = @open_orders.map(&:delivery_date).compact.min
  end
end
