class ReviewMailer < ApplicationMailer
  def new_review
    @user = params[:user]
    mail(to: @user.email, subject: 'Recenzie nouă!')
  end

  def new_review_to_admin
    @user = params[:user]
    mail(to: 'urs4q3@gmail.com', subject: 'Recenzie nouă de verificat')
  end
end
