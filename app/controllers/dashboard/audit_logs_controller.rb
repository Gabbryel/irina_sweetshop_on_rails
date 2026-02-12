class Dashboard::AuditLogsController < ApplicationController
  require 'csv'
  
  before_action :authenticate_user!
  before_action :require_admin
  skip_after_action :track_audit_log

  def index
    # Base scope with policy
    @audit_logs = policy_scope(AuditLog).includes(:user).recent
    
    # Apply filters
    @audit_logs = @audit_logs.by_user(params[:user_id]) if params[:user_id].present?
    @audit_logs = @audit_logs.by_action(params[:action_filter]) if params[:action_filter].present?
    @audit_logs = @audit_logs.by_auditable_type(params[:auditable_type]) if params[:auditable_type].present?
    
    # Date range filter
    if params[:start_date].present?
      @audit_logs = @audit_logs.where('created_at >= ?', params[:start_date].to_date.beginning_of_day)
    end
    if params[:end_date].present?
      @audit_logs = @audit_logs.where('created_at <= ?', params[:end_date].to_date.end_of_day)
    end
    
    # Search filter (for IP, user agent, email)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @audit_logs = @audit_logs.left_joins(:user)
        .where('audit_logs.ip_address ILIKE ? OR audit_logs.user_agent ILIKE ? OR users.email ILIKE ?', 
               search_term, search_term, search_term)
    end

    # Snapshot for summary metrics before pagination
    filtered_scope = @audit_logs
    @summary_total = filtered_scope.count
    @summary_today = filtered_scope.where('created_at >= ?', Time.zone.now.beginning_of_day).count
    @summary_failed_logins = filtered_scope.where(action: AuditLog::ACTIONS[:failed_login]).count
    @summary_unique_users = filtered_scope.where.not(user_id: nil).distinct.count(:user_id)
    @summary_unique_ips = filtered_scope.where.not(ip_address: [nil, '']).distinct.count(:ip_address)
    @action_distribution = filtered_scope.reorder(nil).group(:action).count

    # Pagination
    @pagy, @audit_logs = pagy(@audit_logs, items: 25)
    
    # Data for filters
    @users = User.order(:email).pluck(:email, :id)
    @actions = AuditLog::ACTIONS.values
    @auditable_types = AuditLog.distinct.pluck(:auditable_type).compact.sort
  end

  def show
    @audit_log = AuditLog.find(params[:id])
    authorize @audit_log
  end

  def statistics
    authorize AuditLog
    
    @total_logs = AuditLog.count
    @today_logs = AuditLog.today.count
    @week_logs = AuditLog.this_week.count
    @month_logs = AuditLog.this_month.count
    
    # Authentication stats
    @login_count = AuditLog.where(action: 'login').this_month.count
    @logout_count = AuditLog.where(action: 'logout').this_month.count
    @failed_login_count = AuditLog.where(action: 'failed_login').this_month.count
    
    # CRUD stats
    @create_count = AuditLog.where(action: 'create').this_month.count
    @update_count = AuditLog.where(action: 'update').this_month.count
    @destroy_count = AuditLog.where(action: 'destroy').this_month.count
    
    # Top users
    @top_users = AuditLog.this_month
      .joins(:user)
      .group('users.email')
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Activity by day (last 30 days)
    @daily_activity = AuditLog
      .where('created_at >= ?', 30.days.ago)
      .group_by_day(:created_at)
      .count
    
    # Activity by action type (last 30 days)
    @activity_by_action = AuditLog
      .where('created_at >= ?', 30.days.ago)
      .group(:action)
      .count
    
    # Activity by hour (today)
    @hourly_activity = AuditLog
      .where('created_at >= ?', Time.zone.now.beginning_of_day)
      .group_by_hour(:created_at)
      .count
      
    # Most active resources
    @active_resources = AuditLog
      .where.not(auditable_type: nil)
      .this_month
      .group(:auditable_type)
      .count
      .sort_by { |_, count| -count }
  end

  def export
    authorize AuditLog
    
    @audit_logs = AuditLog.includes(:user).recent
    
    # Apply same filters as index
    @audit_logs = @audit_logs.by_user(params[:user_id]) if params[:user_id].present?
    @audit_logs = @audit_logs.by_action(params[:action_filter]) if params[:action_filter].present?
    @audit_logs = @audit_logs.by_auditable_type(params[:auditable_type]) if params[:auditable_type].present?
    
    if params[:start_date].present?
      @audit_logs = @audit_logs.where('created_at >= ?', params[:start_date].to_date.beginning_of_day)
    end
    if params[:end_date].present?
      @audit_logs = @audit_logs.where('created_at <= ?', params[:end_date].to_date.end_of_day)
    end
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@audit_logs), 
                  filename: "audit_logs_#{Date.today}.csv",
                  type: 'text/csv'
      end
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: 'Nu ai permisiunea necesară.' unless current_user&.admin?
  end

  def generate_csv(audit_logs)
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'User', 'Action', 'Auditable Type', 'Auditable ID', 'IP Address', 'Created At']
      
      audit_logs.find_each do |log|
        csv << [
          log.id,
          log.user_email,
          log.human_action,
          log.auditable_type,
          log.auditable_id,
          log.ip_address,
          log.created_at.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end
    end
  end
end
