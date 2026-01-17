module AuditTrackable
  extend ActiveSupport::Concern

  included do
    after_action :track_audit_log, only: [:create, :update, :destroy]
  end

  private

  def track_audit_log
    return unless should_track_audit?
    
    action_name = determine_audit_action
    auditable = determine_auditable_object
    changes = extract_changes(auditable)

    AuditLog.log_action(
      user: current_user,
      action: action_name,
      auditable: auditable,
      changes: changes,
      request: request
    )
  rescue => e
    # Log the error but don't break the request
    Rails.logger.error("Audit tracking failed: #{e.message}")
  end

  def should_track_audit?
    # Don't track if user is not authenticated (for public actions)
    # or if the action is not trackable
    current_user.present? && trackable_action?
  end

  def trackable_action?
    %w[create update destroy].include?(action_name)
  end

  def determine_audit_action
    case action_name
    when 'create' then AuditLog::ACTIONS[:create]
    when 'update' then AuditLog::ACTIONS[:update]
    when 'destroy' then AuditLog::ACTIONS[:destroy]
    end
  end

  def determine_auditable_object
    # Try to find the object from instance variables
    # This works for most REST controllers
    controller_name = self.class.name.gsub('Controller', '').singularize
    instance_var = "@#{controller_name.underscore}"
    instance_variable_get(instance_var)
  end

  def extract_changes(auditable)
    return {} unless auditable
    
    if auditable.respond_to?(:saved_changes) && auditable.saved_changes.present?
      # For create/update actions
      auditable.saved_changes
    elsif auditable.respond_to?(:attributes)
      # For destroy actions, capture the final state
      { deleted: auditable.attributes }
    else
      {}
    end
  end
end
