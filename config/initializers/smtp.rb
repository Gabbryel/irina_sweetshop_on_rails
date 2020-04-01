ActionMailer::Base.smtp_settings = {
  address: "mail.irinasweet.ro",
  port: 26,
  domain: 'irinasweet.ro',
  user_name: ENV['MAIL_ADDRESS'],
  password: ENV['APP_PASS'],
  authentication: :plain,
  enable_starttls_auto: true,
  openssl_verify_mode: 'none'
}