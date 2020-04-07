ActionMailer::Base.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: 'gmail.com',
  user_name: ENV['MAIL_ADDRESS'],
  password: ENV['APP_PASS'],
  authentication: :login,
  enable_starttls_auto: true
  }