ActionMailer::Base.smtp_settings = {
  address: ENV.fetch('SMTP_ADDRESS', 'mail.irinasweet.ro'),
  port: ENV.fetch('SMTP_PORT', 465).to_i,
  domain: ENV.fetch('SMTP_DOMAIN', 'irinasweet.ro'),
  user_name: ENV.fetch('SMTP_USERNAME', 'comenzi@irinasweet.ro'),
  password: ENV['SMTP_PASSWORD'],
  authentication: :login,
  ssl: true,
  enable_starttls_auto: true
}

# Ensure Action Mailer uses SMTP unless explicitly overridden per environment.
ActionMailer::Base.delivery_method = :smtp