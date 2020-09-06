class BookingsController < ApplicationController
  respond_to :html

  def index
    @bookings = current_user.bookings
    respond_with @bookings
  end

  def show
    @booking = current_user.bookings.find params[:id]
    respond_with @booking
  end
end
