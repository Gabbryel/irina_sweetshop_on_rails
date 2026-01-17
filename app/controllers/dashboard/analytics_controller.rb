class Dashboard::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  skip_after_action :verify_policy_scoped

  def index
    authorize :analytics, :index?
    
    # Visit statistics
    @total_visits = Ahoy::Visit.count
    @today_visits = Ahoy::Visit.where('started_at >= ?', Time.zone.now.beginning_of_day).count
    @week_visits = Ahoy::Visit.where('started_at >= ?', 1.week.ago).count
    @month_visits = Ahoy::Visit.where('started_at >= ?', 1.month.ago).count
    
    # Event statistics
    @total_events = Ahoy::Event.count
    @today_events = Ahoy::Event.where('time >= ?', Time.zone.now.beginning_of_day).count
    
    # Unique visitors
    @unique_visitors_today = Ahoy::Visit.where('started_at >= ?', Time.zone.now.beginning_of_day).distinct.count(:visitor_token)
    @unique_visitors_week = Ahoy::Visit.where('started_at >= ?', 1.week.ago).distinct.count(:visitor_token)
    @unique_visitors_month = Ahoy::Visit.where('started_at >= ?', 1.month.ago).distinct.count(:visitor_token)
    
    # Visits by day (last 30 days)
    @visits_by_day = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group_by_day(:started_at)
      .count
    
    # Top pages (last 30 days)
    @top_pages = Ahoy::Event
      .where('time >= ?', 30.days.ago)
      .where.not(properties: {})
      .group('properties')
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Browser statistics
    @browsers = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group(:browser)
      .count
      .sort_by { |_, count| -count }
    
    # OS statistics
    @operating_systems = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group(:os)
      .count
      .sort_by { |_, count| -count }
    
    # Device type statistics
    @device_types = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group(:device_type)
      .count
    
    # Visits by hour (today)
    @hourly_visits = Ahoy::Visit
      .where('started_at >= ?', Time.zone.now.beginning_of_day)
      .group_by_hour(:started_at)
      .count
    
    # Top events (last 30 days)
    @top_events = Ahoy::Event
      .where('time >= ?', 30.days.ago)
      .group(:name)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Registered users activity
    @registered_user_visits = Ahoy::Visit
      .where.not(user_id: nil)
      .where('started_at >= ?', 30.days.ago)
      .count
    
    @guest_visits = Ahoy::Visit
      .where(user_id: nil)
      .where('started_at >= ?', 30.days.ago)
      .count
  end

  private

  def require_admin
    redirect_to root_path, alert: 'Nu ai permisiunea necesară.' unless current_user&.admin?
  end
end
