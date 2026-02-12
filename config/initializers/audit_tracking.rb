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

# Track failed login attempts only for real sign-in submissions.
# `after_failed_fetch` fires for many unauthenticated requests and can flood logs.
Warden::Manager.before_failure do |env, opts|
  request = ActionDispatch::Request.new(env)
  params = request.params || {}

  user_scope = opts[:scope].to_s == 'user'
  sign_in_path = request.path.to_s.end_with?('/users/sign_in')
  devise_session_create = params['controller'] == 'devise/sessions' && params['action'] == 'create'
  login_attempt = request.post? && (sign_in_path || devise_session_create)

  next unless user_scope && login_attempt

  email = params.dig('user', 'email').to_s.strip.downcase
  next if email.blank?

  duplicate_recent_failure = AuditLog
    .where(action: AuditLog::ACTIONS[:failed_login], ip_address: request.remote_ip)
    .where("change_data ->> 'email' = ?", email)
    .where('created_at >= ?', 30.seconds.ago)
    .exists?
  next if duplicate_recent_failure

  reason = opts[:message].to_s.presence || 'Authentication failed'

  AuditLog.log_action(
    user: nil,
    action: AuditLog::ACTIONS[:failed_login],
    changes: { email: email, reason: reason, path: request.path },
    request: request
  )
end
