class ItemsController < ApplicationController
  include CurrentCartConcern
  before_action :set_cart, only: [:create]
  skip_before_action :authenticate_user!, only: [:create]

  def new
    @item = authorize Item.new
  end

  def create
    @item = authorize Item.new(item_params)
    @item.cart = @cart
    @item.user = current_user if current_user.present?

    if @item.save
      redirect_to cart_path
    else
      redirect_to cart_path, alert: 'Produsul nu a putut fi adăugat în coș.'
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
    params.require(:item).permit(:name, :quantity, :kg_buc, :price_cents)
  end
end
