module Dashboard
  class OrdersController < ApplicationController
    before_action :set_order, only: %i[show update destroy resend_emails]

    def index
      authorize Cart, :dashboard_index?

      base_scope = policy_scope(Cart)
      @status_filter = sanitized_status(params[:status])
      @delivery_filter = params[:delivery].presence
      @only_open = ActiveModel::Type::Boolean.new.cast(params[:only_open])
      @query = params[:query].to_s.strip
      orders = base_scope.includes(:items, :user)

      orders = orders.where(status: @status_filter) if @status_filter.present?
      orders = apply_delivery_filter(orders, @delivery_filter)
      orders = apply_open_filter(orders, @only_open)
      orders = apply_search(orders, @query) if @query.present?
      orders = apply_sorting(orders, params[:order]).order(created_at: :desc)

      @pagy, @orders = pagy(orders, items: 20)

      @status_counts = base_scope.group(:status).count
      @revenue_total = money_from_cents(Item.joins(:cart).where(carts: { status: Cart::STATUSES[:delivered] }).sum(:total_cents))
      @revenue_this_month = money_from_cents(Item.joins(:cart)
                                              .where(carts: { status: Cart::STATUSES[:delivered] })
                      .where('carts.updated_at >= ?', Time.current.beginning_of_month)
                      .sum(:total_cents))
      @open_orders = base_scope.where(status: [Cart::STATUSES[:no_status], Cart::STATUSES[:seen], Cart::STATUSES[:in_production], Cart::STATUSES[:ready]]).order(updated_at: :desc).limit(5)

      @today_orders = base_scope.where(delivery_date: Date.current)
      @tomorrow_orders = base_scope.where(delivery_date: Date.tomorrow)
      @next_week_orders = base_scope.where(delivery_date: (Date.current + 2.days)..(Date.current + 7.days))
    end

    def show
      authorize @order, :dashboard_show?
      @items = @order.items.includes(:recipe)
    end

    def update
      authorize @order, :dashboard_update?

      previous_status = @order.status

      if @order.update(order_params)
        send_status_update(@order, previous_status)
        send_completion_emails(@order, previous_status)
        redirect_back fallback_location: dashboard_order_path(@order), notice: 'Comanda a fost actualizată.'
      else
        redirect_back fallback_location: dashboard_order_path(@order), alert: @order.errors.full_messages.to_sentence
      end
    end

    def destroy
      authorize @order, :dashboard_destroy?

      if @order.destroy
        redirect_to dashboard_orders_path, notice: 'Comanda a fost ștearsă.'
      else
        redirect_back fallback_location: dashboard_orders_path, alert: 'Comanda nu a putut fi ștearsă.'
      end
    end

    def resend_emails
      authorize @order, :dashboard_resend?

      OrderMailer.with(order: @order).admin_notification.deliver_later
      OrderMailer.with(order: @order).customer_confirmation.deliver_later if @order.contact_email.present?

      redirect_back fallback_location: dashboard_orders_path, notice: 'Email-urile au fost retrimise.'
    rescue StandardError => e
      Rails.logger.error("Resend emails failed for order ##{@order.id}: #{e.message}")
      redirect_back fallback_location: dashboard_orders_path, alert: 'Email-urile nu au putut fi retrimise.'
    end

    private

    def set_order
      @order = Cart.includes(:items, :user).find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :admin_notes, :customer_full_name, :customer_phone, :delivery_address, :email, :county, :delivery_date, :method_of_delivery)
    end

    def sanitized_status(status_param)
      return unless status_param.present?

      status_param = status_param.to_s
      Cart::STATUSES.value?(status_param) ? status_param : nil
    end

    def apply_search(scope, query)
      sql = <<~SQL.squish
        LOWER(COALESCE(customer_full_name, '')) LIKE :q OR
        LOWER(COALESCE(email, '')) LIKE :q OR
        LOWER(COALESCE(customer_phone, '')) LIKE :q OR
        LOWER(COALESCE(delivery_address, '')) LIKE :q OR
        LOWER(COALESCE(county, '')) LIKE :q OR
        LOWER(COALESCE(method_of_delivery, '')) LIKE :q OR
        LOWER(COALESCE(stripe_checkout_session_id, '')) LIKE :q OR
        LOWER(COALESCE(guest_token, '')) LIKE :q
      SQL
      scope.where(sql, q: "%#{query.downcase}%")
    end

    def apply_sorting(scope, order_param)
      case order_param
      when 'oldest'
        scope.reorder(created_at: :asc)
      else
        scope
      end
    end

    def apply_delivery_filter(scope, filter)
      case filter
      when 'today'
        scope.where(delivery_date: Date.current)
      when 'tomorrow'
        scope.where(delivery_date: Date.tomorrow)
      when 'next_7_days'
        scope.where(delivery_date: Date.current..(Date.current + 7.days))
      when 'past'
        scope.where('delivery_date < ?', Date.current)
      when 'future'
        scope.where('delivery_date > ?', Date.current)
      else
        scope
      end
    end

    def apply_open_filter(scope, only_open)
      return scope unless only_open

      scope.where(status: [Cart::STATUSES[:no_status], Cart::STATUSES[:seen], Cart::STATUSES[:in_production], Cart::STATUSES[:ready]])
    end

    def money_from_cents(cents)
      Money.new(cents || 0, Money.default_currency)
    end

    def send_status_update(order, previous_status)
      return if order.status == previous_status
      return if order.guest_no_email?
      return unless order.contact_email.present?

      OrderMailer.with(order: order).status_update.deliver_later
    rescue StandardError => e
      Rails.logger.error("OrderMailer status update failed for cart ##{order.id}: #{e.message}")
    end

    def send_completion_emails(order, previous_status)
      return unless previous_status != Cart::STATUSES[:delivered] && order.status == Cart::STATUSES[:delivered]

      OrderMailer.with(order: order).admin_notification.deliver_later
      OrderMailer.with(order: order).customer_confirmation.deliver_later if order.contact_email.present? && !order.guest_no_email?
    rescue StandardError => e
      Rails.logger.error("OrderMailer failed for cart ##{order.id}: #{e.message}")
    end
  end
end
