class ItemsController < ApplicationController
  include CurrentCartConcern
  before_action :set_cart, only: [:create]

  def new
    @item = authorize Item.new
  end

  def create
    @item = authorize Item.new(item_params)
    @cart = Cart.find(session[:cart_id])
    @item.cart = @cart
    if @item.save!
      redirect_to cart_path
    end
  end

  def edit
    @item = Item.find(params[:id])
    authorize @item
  end

  def update
    @item = Item.find(params[:id])
    authorize @item
    @item.update(item_params)
    redirect_to cart_path
  end

  def destroy
    @item = authorize Item.find(params[:id])
    @item.destroy
    redirect_to cart_path
  end

  private

  def item_params
    params.require(:item).permit(:user_id, :cart_id, :name, :quantity, :kg_buc, :price_cents, :total_cents)
  end
end
