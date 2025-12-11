class OrderMailer < ApplicationMailer
  ADMIN_EMAIL = 'office@irinasweet.ro'.freeze

  def admin_notification
    @order = params[:order]
    @items = @order.items.includes(:recipe)
    mail(to: ADMIN_EMAIL, subject: "Comanda finalizată ##{@order.id}")
  end

  def customer_confirmation
    @order = params[:order]
    @items = @order.items.includes(:recipe)
    mail(to: @order.contact_email, subject: "Confirmare comandă ##{@order.id}")
  end

  def status_update
    @order = params[:order]
    @items = @order.items.includes(:recipe)
    mail(to: @order.contact_email, subject: "Actualizare status comandă ##{@order.id}: #{@order.status_label}")
  end

  def payment_reminder
    @order = params[:order]
    @items = @order.items.includes(:recipe)
    @public_order_number = @order.public_order_number
    mail(to: @order.contact_email, subject: "Comanda ta este încă în așteptare de plată")
  end
end
