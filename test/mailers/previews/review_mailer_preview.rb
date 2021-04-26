# Preview all emails at http://localhost:3000/rails/mailers/review_mailer
class ReviewMailerPreview < ActionMailer::Preview
  def new_review
    user = User.first
    review = Review.first
    ReviewMailer.with(user: user, review: review).new_review
  end

  def new_review_to_admin
    user = User.first
    review = Review.first
    ReviewMailer.with(user: user, review: review).new_review_to_admin
  end
end
