class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :reviews, dependent: :destroy
  has_one :cart
  has_many :items, dependent: :destroy

  after_create :send_welcome_email
  after_create :send_notice_to_admin

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end
  def send_notice_to_admin
    UserMailer.with(user: self).notice_to_admin.deliver_now
  end

end
