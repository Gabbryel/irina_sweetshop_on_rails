# frozen_string_literal: true

namespace :delivery do
  desc "Block the next N days for delivery (defaults to starting tomorrow)"
  task :block, %i[days start_date reason] => :environment do |_t, args|
    days = args[:days].to_i
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.current + 1.day
    reason = args[:reason].presence

    if days <= 0
      puts "Usage: rake delivery:block[days,start_date(optional),reason(optional)]"
      exit(1)
    end

    result = DeliveryBlocker.block_days(days:, start_date:, reason:)
    puts "Blocked #{result.created}/#{result.total} days (#{result.skipped} already blocked)."
  rescue ArgumentError => e
    warn "Error: #{e.message}"
    exit(1)
  end
end
