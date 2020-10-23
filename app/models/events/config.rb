module Events
  class Config
    attr_reader :source

    def initialize(source = Rails.application.config.bookings_config)
      @source = source
    end

    def booking_cancellation_cooling_off_period
      to_minutes_duration :booking_cancellation_cooling_off_period_in_minutes
    end

    def booking_confirmation_period
      to_minutes_duration :booking_confirmation_period_in_minutes
    end

    def booking_type
      source[:booking_type]&.to_sym
    end

    def entry_selection_strategy
      source[:entry_selection_strategy]&.to_sym
    end

    private

    def to_minutes_duration(attr)
      source[attr]&.to_i&.minutes
    end
  end
end
