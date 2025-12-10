# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview customer confirmation
  def customer_confirmation
    order = Cart.delivered_status.last || Cart.last || sample_order
    OrderMailer.with(order: order).customer_confirmation
  end

  # Preview admin notification
  def admin_notification
    order = Cart.delivered_status.last || Cart.last || sample_order
    OrderMailer.with(order: order).admin_notification
  end

  # Preview customer status update
  def status_update
    order = Cart.in_production_status.last || Cart.delivered_status.last || Cart.last || sample_order(status: Cart::STATUSES[:in_production])
    OrderMailer.with(order: order).status_update
  end

  private

  def sample_order(status: Cart::STATUSES[:delivered])
    cart = Cart.new(
      id: 9999,
      customer_full_name: 'Preview User',
      customer_phone: '07xx-xxxxxx',
      email: 'preview@example.com',
      delivery_date: Date.current + 2.days,
      method_of_delivery: 'delivery',
      county: 'Bacău',
      delivery_address: 'Str. Exemplu 123',
      customer_notes: 'Fără zahăr pe glazură.',
      status: status
    )
    cart.items.build(name: 'Tort Ciocolată', quantity: 1, price_cents: 45000, kg_buc: 'buc')
    cart
  end
end
