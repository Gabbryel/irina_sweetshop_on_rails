module Dashboard
  class DeliveryDatesController < ApplicationController
    MAX_CALENDAR_RANGE_DAYS = 90
    MAX_SELECTABLE_RANGE_DAYS = Cart::MAX_DELIVERY_WINDOW_DAYS

    before_action :authorize_delivery_dates
    before_action :load_calendar_context, only: :index

    def index; end

    def block_range
      authorize DeliveryBlockDate

      days = params[:days].to_i
      start_date = params[:start_date].presence ? Date.iso8601(params[:start_date]) : Date.current + 1.day
      reason = params[:reason].presence

      if days <= 0
        return redirect_to dashboard_delivery_dates_path, alert: 'Introduceți un număr pozitiv de zile.'
      end

      result = DeliveryBlocker.block_days(days: days, start_date: start_date, reason: reason)
      notice = "Zile blocate: #{result.created}/#{result.total}. #{result.skipped} existau deja.".strip
      redirect_to dashboard_delivery_dates_path, notice: notice
    rescue ArgumentError => e
      redirect_to dashboard_delivery_dates_path, alert: e.message
    end

    def toggle
      date = parsed_date
      return respond_with_error('Data selectată nu este validă.') unless date
      return respond_with_error("Datele aflate la mai mult de #{MAX_SELECTABLE_RANGE_DAYS} zile sunt dezactivate implicit.") if date > Date.current + MAX_SELECTABLE_RANGE_DAYS.days

      delivery_block = DeliveryBlockDate.find_by(blocked_on: date)

      blocked = if delivery_block.present?
                  delivery_block.destroy
                  false
                else
                  DeliveryBlockDate.create!(blocked_on: date, reason: params[:reason].presence)
                  true
                end

      DeliveryCalendar.reset_cache!
      load_calendar_context

      notice_message = blocked ? 'Zi blocată pentru livrare.' : 'Zi disponibilă din nou pentru livrare.'

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = notice_message
          render turbo_stream: [
            turbo_stream.update(
              'delivery-calendar-frame',
              partial: 'dashboard/delivery_dates/calendar',
              locals: calendar_locals
            ),
            turbo_stream.update('flash-messages', partial: 'shared/flashes')
          ]
        end

        format.html do
          redirect_to dashboard_delivery_dates_path, notice: notice_message
        end

        format.json { render json: { blocked_on: date.iso8601, blocked: blocked } }
      end
    rescue ActiveRecord::RecordInvalid => e
      respond_with_error(e.record.errors.full_messages.to_sentence)
    end

    private

    def authorize_delivery_dates
      authorize DeliveryBlockDate
    end

    def load_calendar_context
      @start_date = Date.current
      @end_date = @start_date + (MAX_CALENDAR_RANGE_DAYS - 1).days
      @max_window_days = MAX_SELECTABLE_RANGE_DAYS
      @blocked_dates = policy_scope(DeliveryBlockDate)
                        .where(blocked_on: @start_date..@end_date)
                        .order(:blocked_on)
                        .pluck(:blocked_on)
    end

    def parsed_date
      return if params[:blocked_on].blank?

      Date.iso8601(params[:blocked_on])
    rescue ArgumentError
      nil
    end

    def respond_with_error(message, status: :unprocessable_entity)
      load_calendar_context unless defined?(@start_date)

      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = message
          render turbo_stream: [
            turbo_stream.update(
              'delivery-calendar-frame',
              partial: 'dashboard/delivery_dates/calendar',
              locals: calendar_locals
            ),
            turbo_stream.update('flash-messages', partial: 'shared/flashes')
          ], status: status
        end

        format.html do
          redirect_to dashboard_delivery_dates_path, alert: message
        end

        format.json { render json: { error: message }, status: status }
      end
    end

    def calendar_locals
      {
        start_date: @start_date,
        end_date: @end_date,
        blocked_dates: @blocked_dates,
        max_window_days: @max_window_days
      }
    end
  end
end
