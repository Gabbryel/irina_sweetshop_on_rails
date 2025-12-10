# Ensure ActionMailer background jobs run with the application's configured Time.zone
# This prevents emails rendered in background workers from using the system/UTC timezone
# and makes `l(object.created_at.in_time_zone(Time.zone))` produce consistent results.
Rails.application.config.after_initialize do
  if defined?(ActionMailer::MailDeliveryJob)
    ActionMailer::MailDeliveryJob.class_eval do
      around_perform do |job, block|
        configured_zone = Rails.application.config.time_zone.presence || 'UTC'
        # Use Time.use_zone to temporarily set Time.zone for the duration of the job
        Time.use_zone(configured_zone) do
          block.call
        end
      end
    end
  end
end
