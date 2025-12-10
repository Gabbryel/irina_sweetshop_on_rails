# frozen_string_literal: true

class DeliveryBlocker
  Result = Struct.new(:created, :skipped, :total, keyword_init: true)

  class << self
    def block_days(days:, start_date: Date.current + 1.day, reason: nil)
      raise ArgumentError, "days must be positive" unless days.to_i.positive?

      from = start_date.to_date
      to = from + (days.to_i - 1).days
      block_range(from:, to:, reason:)
    end

    def block_range(from:, to:, reason: nil)
      dates = normalize_range(from, to)
      created = 0
      skipped = 0

      DeliveryBlockDate.transaction do
        dates.each do |date|
          record = DeliveryBlockDate.find_or_initialize_by(blocked_on: date)
          if record.persisted?
            skipped += 1
            next
          end

          record.reason = reason if reason.present?
          if record.save
            created += 1
          else
            raise ActiveRecord::Rollback, record.errors.full_messages.to_sentence
          end
        end
      end

      DeliveryCalendar.reset_cache!
      Result.new(created:, skipped:, total: dates.size)
    end

    private

    def normalize_range(from, to)
      from_date = from.to_date
      to_date = to.to_date
      raise ArgumentError, "end date must be on or after start date" if to_date < from_date

      (from_date..to_date).to_a
    end
  end
end
