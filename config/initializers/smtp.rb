ActionMailer::Base.smtp_settings = {
  address: "mail.irinasweet.ro",
  port: 465,
  domain: 'gmail.com',
  user_name: ENV['MAIL_ADDRESS'],
  password: ENV['MAIL_PASSWORD'],
  authentication: :login,
  enable_starttls_auto: true
}