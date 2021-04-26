# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.with(user: user).welcome
  end

  def notice_to_admin
    user = User.first
    UserMailer.with(user: user).notice_to_admin
end

end
