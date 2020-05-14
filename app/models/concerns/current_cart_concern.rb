module CurrentCartConcern

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    Cart.destroy_all
    @cart = Cart.new
    @cart.user = current_user
    @cart.save
    session[:cart_id] = @cart.id
  end
end