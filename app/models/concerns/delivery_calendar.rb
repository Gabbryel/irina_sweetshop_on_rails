module DeliveryCalendar
  extend self

  def disabled_dates(_reference_date = Date.current)
    (configured_dates + environment_dates + database_dates).uniq
  end

  def reset_cache!
    @config = nil
  end

  private

  def configured_dates
    Array(config.fetch('disabled_dates', [])).filter_map { |value| parse_date(value) }
  end

  def environment_dates
    raw = ENV.fetch('DISABLED_DELIVERY_DATES', '').to_s
    return [] if raw.blank?

    raw.split(',').filter_map { |value| parse_date(value) }
  end

  def database_dates
    DeliveryBlockDate.pluck(:blocked_on)
  rescue ActiveRecord::StatementInvalid
    []
  end

  def config
    @config ||= Rails.application.config_for(:delivery_calendar)
  rescue StandardError
    @config = {}
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
