module Bookings
  class ApplicationController < ::ApplicationController
    respond_to :html

    before_action :find_booking

    def event_config
      @event_config ||= Events::Config.new(@booking.event.config_data)
    end

    private

    def find_booking
      logger.warn "#find_booking should use pundit scope here..."
      @booking = Booking.find params[:booking_id]
    end
  end
end
