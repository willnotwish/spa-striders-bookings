module Bookings
  class ApplicationController < ::ApplicationController
    respond_to :html

    before_action :find_booking

    private

    def find_booking
      logger.warn "#find_booking should use pundit scope here..."
      @booking = Booking.find params[:booking_id]
    end
  end
end
