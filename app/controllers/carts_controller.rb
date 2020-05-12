class CartsController < ApplicationController
  include CurrentCartConcern
  

  def show
      set_cart
      @cart = authorize Cart.find(session[:cart_id])
      @items = Item.where(cart_id: @cart.id).order('id ASC')
  end
end
