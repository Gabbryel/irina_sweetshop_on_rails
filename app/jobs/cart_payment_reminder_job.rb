class CartPaymentReminderJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    cart = Cart.find_by(id: cart_id)
    return if cart.blank?
    return if cart.paid?
    return unless cart.no_status_status?
    return if cart.items.empty?
    return if cart.reminder_sent_at.present?

    if cart.contact_email.present? && !cart.guest_no_email
      OrderMailer.with(order: cart).payment_reminder.deliver_later
    end

    cart.update!(reminder_sent_at: Time.current)
  rescue StandardError => e
    Rails.logger.error("CartPaymentReminderJob failed for cart ##{cart_id}: #{e.message}")
  end
end
