class DeliveryBlockDate < ApplicationRecord
  validates :blocked_on, presence: true, uniqueness: true

  scope :upcoming, -> { where('blocked_on >= ?', Date.current).order(:blocked_on) }
  scope :past, -> { where('blocked_on < ?', Date.current).order(blocked_on: :desc) }

  def label
    reason.presence || I18n.l(blocked_on)
  end
end
