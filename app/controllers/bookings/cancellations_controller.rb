module Bookings
  class CancellationsController < ApplicationController
    def new
      @cancellation = Cancellation.new(booking: @booking, current_user: current_user)
      respond_with :booking, @cancellation
    end

    def create
      @cancellation = Cancellation.create(booking: @booking, current_user: current_user)
      respond_with :booking, @cancellation, location: @booking
    end
  end
end
