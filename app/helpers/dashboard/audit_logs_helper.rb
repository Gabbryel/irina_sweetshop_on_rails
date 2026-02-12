module Dashboard::AuditLogsHelper
  ACTION_VARIANTS = {
    'create' => 'success',
    'update' => 'primary',
    'destroy' => 'danger',
    'login' => 'info',
    'logout' => 'secondary',
    'failed_login' => 'warning'
  }.freeze

  ACTION_ICONS = {
    'create' => 'fa-plus',
    'update' => 'fa-pen',
    'destroy' => 'fa-trash',
    'login' => 'fa-right-to-bracket',
    'logout' => 'fa-right-from-bracket',
    'failed_login' => 'fa-triangle-exclamation'
  }.freeze

  def audit_action_variant(action)
    ACTION_VARIANTS.fetch(action.to_s, 'secondary')
  end

  def audit_action_icon(action)
    ACTION_ICONS.fetch(action.to_s, 'fa-circle')
  end
end
