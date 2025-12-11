module CurrentCartConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_cart if respond_to?(:helper_method, true)
  end

  INACTIVITY_TIMEOUT = 30.minutes

  private

  def current_cart
    return @current_cart if defined?(@current_cart)

    expire_cart_session_if_stale!

    cart = if current_user.present?
             Cart.fetch_for_user(current_user, session)
           else
             fetch_guest_cart_from_session
           end

    remember_cart_session(cart) if cart.present?

    @current_cart = cart
  end

  def set_cart
    @cart = current_cart
  end

  def ensure_cart!
    return current_cart if current_cart.present?

    cart = if current_user.present?
             Cart.create!(user: current_user)
           else
             Cart.create!
           end

    remember_cart_session(cart)
    @current_cart = cart
  end

  def clear_cart_session!
    session.delete(:cart_id)
    session.delete(:cart_token)
    session.delete(:cart_last_seen_at)
    @current_cart = nil
  end

  def expire_cart_session_if_stale!
    last_seen_raw = session[:cart_last_seen_at]
    return if last_seen_raw.blank?

    begin
      last_seen = Time.zone.parse(last_seen_raw.to_s)
    rescue StandardError
      last_seen = nil
    end

    return if last_seen.present? && last_seen >= INACTIVITY_TIMEOUT.ago

    session.delete(:cart_id)
    session.delete(:cart_token)
    session.delete(:cart_last_seen_at)
    @current_cart = nil
  end

  def fetch_guest_cart_from_session
    token = session[:cart_token]
    cart_id = session[:cart_id]

    cart = Cart.fetch_for_guest(session)
    return cart if cart.present?

    if cart_id.present?
      found = Cart.where(id: cart_id, status: [Cart::STATUSES[:no_status], Cart::STATUSES[:seen], Cart::STATUSES[:in_production], Cart::STATUSES[:ready]]).order(created_at: :desc).first
      return found if found.present?
    end

    nil
  end

  def remember_cart_session(cart)
    session[:cart_id] = cart.id
    session[:cart_token] = cart.guest_token if cart.guest_token.present?
    session[:cart_last_seen_at] = Time.current.iso8601
  end
end