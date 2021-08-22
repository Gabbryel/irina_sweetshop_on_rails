class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome
      @user = params[:user] # Instance variable => available in view
      mail(to: @user.email, subject: 'Bine ai venit pe irinasweet.ro!')
      # This will render a view in `app/views/user_mailer`!
  end
  def notice_to_admin
      @user = params[:user]
      @users = User.all.select { |el| !el.admin }
      mail(to: 'urs4q3@gmail.com', subject: 'Utilizator nou!')
  end
end
