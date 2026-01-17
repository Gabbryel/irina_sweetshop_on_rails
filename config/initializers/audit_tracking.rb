# Track authentication events using Warden callbacks
Warden::Manager.after_authentication do |user, auth, opts|
  request = auth.request
  AuditLog.log_action(
    user: user,
    action: AuditLog::ACTIONS[:login],
    changes: { email: user.email },
    request: request
  )
  
  # Also track with Ahoy
  ahoy = Ahoy::Tracker.new(controller: auth.env['action_controller.instance'])
  ahoy.track "User Login", { user_id: user.id, email: user.email }
end

Warden::Manager.before_logout do |user, auth, opts|
  request = auth.request
  AuditLog.log_action(
    user: user,
    action: AuditLog::ACTIONS[:logout],
    changes: { email: user.email },
    request: request
  )
  
  # Also track with Ahoy
  ahoy = Ahoy::Tracker.new(controller: auth.env['action_controller.instance'])
  ahoy.track "User Logout", { user_id: user.id, email: user.email }
end

# Track failed login attempts
Warden::Manager.after_failed_fetch do |user, auth, opts|
  request = auth.request
  # Get attempted email from request params if available
  email = request.params.dig('user', 'email') || 'unknown'
  
  AuditLog.log_action(
    user: nil,
    action: AuditLog::ACTIONS[:failed_login],
    changes: { email: email, reason: 'Authentication failed' },
    request: request
  )
end
