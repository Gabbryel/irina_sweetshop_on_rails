module Dashboard
  class AnalyticsReport
    PERIOD_OPTIONS = {
      '7d' => 'Ultimele 7 zile',
      '30d' => 'Ultimele 30 zile',
      '90d' => 'Ultimele 90 zile',
      '365d' => 'Ultimele 12 luni',
      'custom' => 'Perioada personalizată'
    }.freeze

    FIXED_PERIOD_DAYS = {
      '7d' => 7,
      '30d' => 30,
      '90d' => 90,
      '365d' => 365
    }.freeze

    ADD_TO_CART_EVENTS = [
      'add_to_cart',
      'added_to_cart',
      'cart_add',
      'add-item-to-cart',
      'add item to cart'
    ].freeze

    CHECKOUT_EVENTS = [
      'begin_checkout',
      'checkout_started',
      'start_checkout',
      'init_checkout',
      'begin checkout'
    ].freeze

    def initialize(params:)
      @params = params.symbolize_keys
      @period = normalize_period(@params[:period])
      @range = build_range
      @source_filter = normalize_text(@params[:source_filter] || @params[:source])
      @country_filter = normalize_text(@params[:country_filter] || @params[:country])
    end

    def call
      {
        filters: filter_payload,
        overview: overview_metrics,
        engagement: engagement_metrics,
        commerce: commerce_metrics,
        funnel: funnel_metrics,
        charts: chart_payload,
        breakdowns: breakdown_payload,
        tables: table_payload
      }
    end

    private

    attr_reader :params, :period, :range, :source_filter, :country_filter

    def filter_payload
      {
        period: period,
        period_options: PERIOD_OPTIONS,
        from: range.begin.to_date,
        to: range.end.to_date,
        source_filter: source_filter,
        country_filter: country_filter,
        available_sources: available_sources,
        available_countries: available_countries,
        range_label: "#{I18n.l(range.begin.to_date, format: :long)} - #{I18n.l(range.end.to_date, format: :long)}"
      }
    end

    def overview_metrics
      {
        visits: visits_count,
        previous_visits: previous_visits_count,
        visits_growth: percentage_change(visits_count, previous_visits_count),
        unique_visitors: unique_visitors_count,
        previous_unique_visitors: previous_unique_visitors_count,
        unique_visitors_growth: percentage_change(unique_visitors_count, previous_unique_visitors_count),
        events: events_count,
        events_per_visit: safe_ratio(events_count, visits_count, 2),
        bounce_rate: bounce_rate,
        avg_session_seconds: average_session_seconds
      }
    end

    def engagement_metrics
      {
        registered_visits: registered_visits_count,
        guest_visits: guest_visits_count,
        new_visitors: new_visitors_count,
        returning_visitors: returning_visitors_count,
        active_countries: active_countries_count,
        active_cities: active_cities_count
      }
    end

    def commerce_metrics
      {
        orders_created: orders_created_count,
        paid_orders: paid_orders_count,
        delivered_orders: delivered_orders_count,
        canceled_orders: canceled_orders_count,
        revenue_cents: revenue_cents,
        average_order_value_cents: average_order_value_cents,
        average_items_per_paid_order: average_items_per_paid_order,
        visit_to_paid_conversion_rate: safe_rate(paid_orders_count, visits_count),
        checkout_completion_rate: safe_rate(paid_orders_count, orders_created_count)
      }
    end

    def funnel_metrics
      base = visits_count
      stages = [
        { key: :visits, label: 'Vizite', count: visits_count },
        { key: :add_to_cart, label: 'Adăugări în coș', count: add_to_cart_events_count },
        { key: :checkout_started, label: 'Checkout început', count: checkout_started_events_count },
        { key: :orders_created, label: 'Comenzi create', count: orders_created_count },
        { key: :paid_orders, label: 'Comenzi plătite', count: paid_orders_count }
      ]

      {
        base_count: base,
        stages: stages.map do |stage|
          stage.merge(rate_from_visits: safe_rate(stage[:count], base))
        end
      }
    end

    def chart_payload
      {
        visits_by_day: visits_scope.group_by_day(:started_at, range: range).count,
        events_by_day: events_scope.where(time: range).group_by_day(:time, range: range).count,
        orders_by_day: orders_scope.group_by_day(:created_at, range: range).count,
        paid_orders_by_day: paid_orders_scope.group_by_day(:paid_at, range: range).count,
        revenue_by_day: revenue_by_day,
        hourly_visits_today: hourly_visits_today,
        visits_by_weekday: visits_by_weekday,
        status_split: order_status_split
      }
    end

    def breakdown_payload
      {
        registered_vs_guest: {
          'Autentificați' => registered_visits_count,
          'Guest' => guest_visits_count
        },
        devices: grouped_counts(visits_scope, :device_type),
        browsers: grouped_counts(visits_scope, :browser, limit: 6),
        operating_systems: grouped_counts(visits_scope, :os, limit: 6),
        countries: grouped_counts(visits_scope, :country, limit: 10),
        regions: grouped_counts(visits_scope, :region, limit: 10),
        cities: grouped_counts(visits_scope, :city, limit: 10)
      }
    end

    def table_payload
      {
        landing_pages: grouped_counts(visits_scope, :landing_page, limit: 12),
        top_referrers: grouped_counts(visits_scope, :referrer, limit: 12),
        top_sources: grouped_counts(visits_scope, :referring_domain, limit: 10),
        source_country_rows: source_country_rows,
        top_events: grouped_counts(events_scope.where(time: range), :name, limit: 12),
        top_products: top_products
      }
    end

    def visits_scope
      @visits_scope ||= begin
        scope = Ahoy::Visit.where(started_at: range)
        scope = scope.where(referring_domain: source_filter) if source_filter.present?
        scope = scope.where(country: country_filter) if country_filter.present?
        scope
      end
    end

    def previous_visits_scope
      @previous_visits_scope ||= begin
        scope = Ahoy::Visit.where(started_at: comparison_range)
        scope = scope.where(referring_domain: source_filter) if source_filter.present?
        scope = scope.where(country: country_filter) if country_filter.present?
        scope
      end
    end

    def events_scope
      @events_scope ||= Ahoy::Event.joins(:visit).merge(visits_scope)
    end

    def visits_count
      @visits_count ||= visits_scope.count
    end

    def previous_visits_count
      @previous_visits_count ||= previous_visits_scope.count
    end

    def unique_visitors_count
      @unique_visitors_count ||= visits_scope.where.not(visitor_token: [nil, '']).distinct.count(:visitor_token)
    end

    def previous_unique_visitors_count
      @previous_unique_visitors_count ||= previous_visits_scope.where.not(visitor_token: [nil, '']).distinct.count(:visitor_token)
    end

    def events_count
      @events_count ||= events_scope.count
    end

    def registered_visits_count
      @registered_visits_count ||= visits_scope.where.not(user_id: nil).count
    end

    def guest_visits_count
      @guest_visits_count ||= [visits_count - registered_visits_count, 0].max
    end

    def average_session_seconds
      @average_session_seconds ||= begin
        durations = visits_scope
          .joins(:events)
          .group('ahoy_visits.id')
          .pluck(Arel.sql('EXTRACT(EPOCH FROM (MAX(ahoy_events.time) - MIN(ahoy_visits.started_at)))'))
          .map(&:to_f)
          .select(&:positive?)

        durations.empty? ? 0 : (durations.sum / durations.size).round
      end
    end

    def bounce_rate
      @bounce_rate ||= begin
        return 0.0 if visits_count.zero?

        bounced_visits = visits_scope
          .left_joins(:events)
          .group('ahoy_visits.id')
          .having('COUNT(ahoy_events.id) <= 1')
          .count
          .size

        safe_rate(bounced_visits, visits_count)
      end
    end

    def new_visitors_count
      @new_visitors_count ||= begin
        tokens_scope = visits_scope.where.not(visitor_token: [nil, '']).select(:visitor_token).distinct
        first_seen = Ahoy::Visit.where(visitor_token: tokens_scope).group(:visitor_token).minimum(:started_at)
        first_seen.count { |_token, started_at| started_at >= range.begin }
      end
    end

    def returning_visitors_count
      @returning_visitors_count ||= [unique_visitors_count - new_visitors_count, 0].max
    end

    def active_countries_count
      @active_countries_count ||= visits_scope.where.not(country: [nil, '']).distinct.count(:country)
    end

    def active_cities_count
      @active_cities_count ||= visits_scope.where.not(city: [nil, '']).distinct.count(:city)
    end

    def orders_scope
      @orders_scope ||= Cart.where(created_at: range)
    end

    def paid_orders_scope
      @paid_orders_scope ||= Cart.where(paid_at: range)
    end

    def paid_items_scope
      @paid_items_scope ||= Item.joins(:cart).where(carts: { paid_at: range })
    end

    def orders_created_count
      @orders_created_count ||= orders_scope.count
    end

    def paid_orders_count
      @paid_orders_count ||= paid_orders_scope.count
    end

    def delivered_orders_count
      @delivered_orders_count ||= Cart.where(fulfilled_at: range, status: Cart::STATUSES[:delivered]).count
    end

    def canceled_orders_count
      @canceled_orders_count ||= Cart.where(cancelled_at: range, status: [Cart::STATUSES[:canceled], Cart::STATUSES[:refunded]]).count
    end

    def revenue_cents
      @revenue_cents ||= paid_items_scope.sum(:total_cents).to_i
    end

    def average_order_value_cents
      return 0 if paid_orders_count.zero?

      (revenue_cents.to_f / paid_orders_count).round
    end

    def average_items_per_paid_order
      return 0.0 if paid_orders_count.zero?

      (paid_items_scope.sum(:quantity).to_f / paid_orders_count).round(2)
    end

    def add_to_cart_events_count
      @add_to_cart_events_count ||= named_event_count(ADD_TO_CART_EVENTS)
    end

    def checkout_started_events_count
      @checkout_started_events_count ||= named_event_count(CHECKOUT_EVENTS)
    end

    def named_event_count(names)
      events_scope.where('LOWER(ahoy_events.name) IN (?)', names.map(&:downcase)).count
    end

    def revenue_by_day
      paid_items_scope
        .group_by_day('carts.paid_at', range: range)
        .sum(:total_cents)
        .transform_values { |cents| (cents.to_f / 100).round(2) }
    end

    def hourly_visits_today
      start_of_today = Time.zone.now.beginning_of_day
      end_of_today = Time.zone.now.end_of_day

      visits_scope
        .where(started_at: start_of_today..end_of_today)
        .group_by_hour(:started_at, format: '%H:00')
        .count
    end

    def visits_by_weekday
      day_names = {
        0 => 'Duminică',
        1 => 'Luni',
        2 => 'Marți',
        3 => 'Miercuri',
        4 => 'Joi',
        5 => 'Vineri',
        6 => 'Sâmbătă'
      }

      raw = visits_scope.group_by_day_of_week(:started_at).count
      (0..6).each_with_object({}) do |index, hash|
        hash[day_names[index]] = raw[index] || 0
      end
    end

    def order_status_split
      status_counts = orders_scope.group(:status).count
      return {} if status_counts.empty?

      status_counts.each_with_object({}) do |(status, count), hash|
        label = Cart::STATUS_LABELS[status.to_s] || status.to_s.humanize
        hash[label] = count
      end
    end

    def top_products
      rows = paid_items_scope
        .left_joins(:recipe, :cakemodel)
        .group(Arel.sql("COALESCE(cakemodels.name, recipes.name, items.name, 'Produs fără nume')"))
        .order(Arel.sql('SUM(items.total_cents) DESC'))
        .limit(10)
        .pluck(
          Arel.sql("COALESCE(cakemodels.name, recipes.name, items.name, 'Produs fără nume')"),
          Arel.sql('SUM(items.quantity)'),
          Arel.sql('SUM(items.total_cents)')
        )

      rows.map do |name, quantity, total_cents|
        {
          name: name,
          quantity: quantity.to_f.round(2),
          revenue_cents: total_cents.to_i
        }
      end
    end

    def source_country_rows
      rows = visits_scope
        .where.not(referring_domain: [nil, ''])
        .where.not(country: [nil, ''])
        .group(:referring_domain, :country)
        .count
        .map do |(source, country), count|
          {
            source: source,
            country: country,
            visits: count
          }
        end

      rows.sort_by { |row| -row[:visits] }.first(20)
    end

    def grouped_counts(scope, column, limit: nil)
      rows = scope
        .group(column)
        .count
        .each_with_object({}) do |(value, count), hash|
          label = normalize_text(value).presence || 'Necunoscut'
          hash[label] = hash.fetch(label, 0) + count
        end

      sorted = rows.sort_by { |_, count| -count }
      sorted = sorted.first(limit) if limit
      sorted.to_h
    end

    def available_sources
      @available_sources ||= Ahoy::Visit
        .where(started_at: range)
        .where.not(referring_domain: [nil, ''])
        .distinct
        .order(:referring_domain)
        .pluck(:referring_domain)
    end

    def available_countries
      @available_countries ||= Ahoy::Visit
        .where(started_at: range)
        .where.not(country: [nil, ''])
        .distinct
        .order(:country)
        .pluck(:country)
    end

    def comparison_range
      @comparison_range ||= begin
        span = (range.end - range.begin).to_i
        comparison_end = range.begin - 1.second
        comparison_start = comparison_end - span
        comparison_start..comparison_end
      end
    end

    def safe_rate(part, total)
      return 0.0 if total.to_i <= 0

      ((part.to_f / total.to_f) * 100).round(1)
    end

    def safe_ratio(numerator, denominator, precision = 2)
      return 0 if denominator.to_i <= 0

      (numerator.to_f / denominator.to_f).round(precision)
    end

    def percentage_change(current, previous)
      return 0.0 if previous.to_i <= 0

      (((current.to_f - previous.to_f) / previous.to_f) * 100).round(1)
    end

    def normalize_period(value)
      key = value.to_s
      PERIOD_OPTIONS.key?(key) ? key : '30d'
    end

    def build_range
      return custom_range if period == 'custom' && custom_range.present?

      days = FIXED_PERIOD_DAYS.fetch(period, 30)
      days.days.ago.beginning_of_day..Time.zone.now.end_of_day
    end

    def custom_range
      from = parse_date(params[:from])
      to = parse_date(params[:to])
      return nil if from.blank? || to.blank? || from > to

      from.beginning_of_day..to.end_of_day
    end

    def parse_date(raw)
      return nil if raw.blank?

      Date.parse(raw.to_s)
    rescue ArgumentError
      nil
    end

    def normalize_text(value)
      value.to_s.strip.presence
    end
  end
end
