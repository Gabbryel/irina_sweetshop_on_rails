class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Scopes for filtering
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_auditable_type, ->(type) { where(auditable_type: type) }
  scope :authentication_events, -> { where(action: ['login', 'logout', 'failed_login']) }
  scope :crud_operations, -> { where(action: ['create', 'update', 'destroy']) }
  scope :today, -> { where('created_at >= ?', Time.zone.now.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }

  # Constants for actions
  ACTIONS = {
    create: 'create',
    update: 'update',
    destroy: 'destroy',
    login: 'login',
    logout: 'logout',
    failed_login: 'failed_login'
  }.freeze

  # Validations
  validates :action, presence: true, inclusion: { in: ACTIONS.values }

  # Methods
  def self.log_action(user:, action:, auditable: nil, changes: {}, request: nil)
    create(
      user: user,
      action: action,
      auditable: auditable,
      change_data: changes,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent,
      request_id: request&.request_id
    )
  end

  def auditable_name
    return 'N/A' unless auditable
    auditable.try(:name) || auditable.try(:title) || "#{auditable_type} ##{auditable_id}"
  end

  def user_email
    user&.email || 'System'
  end

  def human_action
    action.humanize
  end
end
