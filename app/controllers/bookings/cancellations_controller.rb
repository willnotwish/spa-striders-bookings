module Bookings
  class CancellationsController < ApplicationController
    before_action :build_cancellation
    
    def new
      respond_with :booking, @cancellation
    end

    def create
      @cancellation.save
      respond_with :booking, @cancellation, location: @booking
    end

    private

    def build_cancellation
      # Cooling off period is determined by event config, not by user;
      # admins (only) can override.
      @cancellation = Cancellation.new(
        booking: @booking, 
        current_user: current_user,
        cooling_off_period: event_config.booking_cancellation_cooling_off_period)
    end
  end
end
