module Bookings
  class ConfirmationsController < ApplicationController
    def new
      @confirmation = Confirmation.new(booking: @booking)
      respond_with :booking, @confirmation
    end

    def create
      @confirmation = Confirmation.create(booking: @booking)
      respond_with :booking, @confirmation
    end
  end
end
