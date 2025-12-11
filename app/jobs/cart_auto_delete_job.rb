class CartAutoDeleteJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    cart = Cart.find_by(id: cart_id)
    return if cart.blank?
    return if cart.paid?
    return unless cart.no_status_status?

    cart.destroy
  rescue StandardError => e
    Rails.logger.error("CartAutoDeleteJob failed for cart ##{cart_id}: #{e.message}")
  end
end
