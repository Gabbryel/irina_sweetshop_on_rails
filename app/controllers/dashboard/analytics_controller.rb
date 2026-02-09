class Dashboard::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  skip_after_action :verify_policy_scoped

  def index
    authorize :analytics, :index?
    
    # Apply filters from params
    @filtered_source = params[:source_filter]
    @filtered_country = params[:country_filter]
    
    # Visit statistics
    @total_visits = Ahoy::Visit.count
    @today_visits = Ahoy::Visit.where('started_at >= ?', Time.zone.now.beginning_of_day).count
    @yesterday_visits = Ahoy::Visit.where('started_at >= ? AND started_at < ?', 1.day.ago.beginning_of_day, Time.zone.now.beginning_of_day).count
    @week_visits = Ahoy::Visit.where('started_at >= ?', 1.week.ago).count
    @month_visits = Ahoy::Visit.where('started_at >= ?', 1.month.ago).count
    @last_month_visits = Ahoy::Visit.where('started_at >= ? AND started_at < ?', 2.months.ago, 1.month.ago).count
    
    # Event statistics
    @total_events = Ahoy::Event.count
    @today_events = Ahoy::Event.where('time >= ?', Time.zone.now.beginning_of_day).count
    @week_events = Ahoy::Event.where('time >= ?', 1.week.ago).count
    @month_events = Ahoy::Event.where('time >= ?', 1.month.ago).count
    
    # Unique visitors
    @unique_visitors_today = Ahoy::Visit.where('started_at >= ?', Time.zone.now.beginning_of_day).distinct.count(:visitor_token)
    @unique_visitors_week = Ahoy::Visit.where('started_at >= ?', 1.week.ago).distinct.count(:visitor_token)
    @unique_visitors_month = Ahoy::Visit.where('started_at >= ?', 1.month.ago).distinct.count(:visitor_token)
    @total_unique_visitors = Ahoy::Visit.distinct.count(:visitor_token)
    
    # Growth percentages
    @daily_growth = @yesterday_visits > 0 ? ((@today_visits - @yesterday_visits).to_f / @yesterday_visits * 100).round(1) : 0
    @monthly_growth = @last_month_visits > 0 ? ((@month_visits - @last_month_visits).to_f / @last_month_visits * 100).round(1) : 0
    
    # Visits by day (last 30 days)
    @visits_by_day = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group_by_day(:started_at)
      .count
    
    # Visits by week (last 12 weeks)
    @visits_by_week = Ahoy::Visit
      .where('started_at >= ?', 12.weeks.ago)
      .group_by_week(:started_at)
      .count
    
    # Visits by month (last 12 months)
    @visits_by_month = Ahoy::Visit
      .where('started_at >= ?', 12.months.ago)
      .group_by_month(:started_at)
      .count
    
    # Landing pages (most common entry points)
    @landing_pages = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(landing_page: nil)
      .group(:landing_page)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Referrer statistics
    @top_referrers = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(referrer: nil)
      .where.not(referrer: '')
      .group(:referrer)
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
    
    # Geographic statistics
    @countries = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(country: nil)
      .group(:country)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    @regions = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(region: nil)
      .group(:region)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    @cities = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(city: nil)
      .group(:city)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Total visits by country (for summary)
    @total_countries = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(country: nil)
      .distinct
      .count(:country)
    
    @total_cities = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(city: nil)
      .distinct
      .count(:city)
    
    # Combined Source × Location Analysis
    base_scope = Ahoy::Visit.where('started_at >= ?', 30.days.ago)
    base_scope = base_scope.where(referring_domain: @filtered_source) if @filtered_source.present?
    base_scope = base_scope.where(country: @filtered_country) if @filtered_country.present?
    
    @source_by_location = base_scope
      .where.not(referring_domain: nil)
      .where.not(country: nil)
      .group(:referring_domain, :country)
      .count
      .sort_by { |_, count| -count }
      .first(20)
      .group_by { |(domain, _), _| domain }
    
    # Available filter options
    @available_sources = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(referring_domain: nil)
      .distinct
      .pluck(:referring_domain)
      .sort
    
    @available_countries = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .where.not(country: nil)
      .distinct
      .pluck(:country)
      .sort
    
    # Visits by hour (today)
    @hourly_visits = Ahoy::Visit
      .where('started_at >= ?', Time.zone.now.beginning_of_day)
      .group_by_hour(:started_at)
      .count
    
    # Visits by day of week (last 30 days)
    @visits_by_day_of_week = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .group_by_day_of_week(:started_at)
      .count
    
    # Average session duration (estimate based on event timestamps)
    # Since Ahoy doesn't track ended_at by default, we estimate based on events
    visits_with_events = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .joins(:events)
      .select('ahoy_visits.id, ahoy_visits.started_at, MAX(ahoy_events.time) as last_event_time')
      .group('ahoy_visits.id, ahoy_visits.started_at')
      .having('COUNT(ahoy_events.id) > 0')
    
    durations = visits_with_events.map do |v|
      last_event = Ahoy::Event.where(visit_id: v.id).maximum(:time)
      (last_event - v.started_at).to_i if last_event && last_event > v.started_at
    end.compact
    
    @avg_session_duration = durations.any? ? (durations.sum / durations.size) : 0
    
    # Bounce rate (visits with only one event)
    single_event_visits = Ahoy::Visit
      .where('started_at >= ?', 30.days.ago)
      .joins(:events)
      .group('ahoy_visits.id')
      .having('COUNT(ahoy_events.id) = 1')
      .count
    @bounce_rate = @month_visits > 0 ? (single_event_visits.size.to_f / @month_visits * 100).round(1) : 0
    
    # Top events (last 30 days)
    @top_events = Ahoy::Event
      .where('time >= ?', 30.days.ago)
      .group(:name)
      .count
      .sort_by { |_, count| -count }
      .first(10)
    
    # Events by day (last 30 days)
    @events_by_day = Ahoy::Event
      .where('time >= ?', 30.days.ago)
      .group_by_day(:time)
      .count
    
    # Registered users activity
    @registered_user_visits = Ahoy::Visit
      .where.not(user_id: nil)
      .where('started_at >= ?', 30.days.ago)
      .count
    
    @guest_visits = Ahoy::Visit
      .where(user_id: nil)
      .where('started_at >= ?', 30.days.ago)
      .count
    
    # New vs returning visitors
    visitor_tokens = Ahoy::Visit.where('started_at >= ?', 30.days.ago).pluck(:visitor_token)
    all_visitor_tokens = Ahoy::Visit.pluck(:visitor_token)
    @new_visitors = (visitor_tokens - all_visitor_tokens.select { |t| visitor_tokens.count(t) == 1 && all_visitor_tokens.count(t) == 1 }.uniq).size
    @returning_visitors = visitor_tokens.size - @new_visitors
  end

  private

  def require_admin
    redirect_to root_path, alert: 'Nu ai permisiunea necesară.' unless current_user&.admin?
  end
end
