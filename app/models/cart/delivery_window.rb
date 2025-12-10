# frozen_string_literal: true

class Cart
  class DeliveryWindow
    attr_reader :min_date, :max_date, :blocked_dates, :max_window_days

    def initialize(min_date:, max_date:, blocked_dates:, max_window_days:)
      @min_date = min_date
      @max_date = max_date
      @blocked_dates = Array(blocked_dates).compact.uniq.sort
      @max_window_days = max_window_days
    end

    def include?(date)
      return false if date.blank?

      date = to_date(date)
      return false if date.nil?

      !before_min?(date) && !after_max?(date) && !blocked_dates.include?(date)
    end

    def before_min?(date)
      date = to_date(date)
      min = to_date(min_date)
      return false if date.nil? || min.nil?

      date < min
    end

    def after_max?(date)
      date = to_date(date)
      max = to_date(max_date)
      return false if date.nil? || max.nil?

      date > max
    end

    def blocked?(date)
      date = to_date(date)
      return false if date.nil?

      blocked_dates.include?(date)
    end

    def data_attributes
      {
        min_date: min_date&.iso8601,
        max_date: max_date&.iso8601,
        disabled_dates: blocked_dates.map(&:iso8601),
        max_window_days: max_window_days
      }
    end

    private

    def to_date(value)
      return value if value.is_a?(Date)

      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
