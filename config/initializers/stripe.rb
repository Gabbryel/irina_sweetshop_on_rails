Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key:      ENV['STRIPE_SECRET_KEY']
}

if Rails.configuration.stripe[:secret_key].present?
  Stripe.api_key = Rails.configuration.stripe[:secret_key]
  Stripe.max_network_retries = 2
  Stripe.api_version = '2022-11-15'
end