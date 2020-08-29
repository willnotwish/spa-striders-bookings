class BookingsController < ApplicationController
  respond_to :html

  def index
    @bookings = current_user.bookings

    respond_with @bookings
  end

  # def new
  #   @booking = current_user.bookings.build(booking_params)

  #   respond_with @booking
  # end

  # def create
  #   @booking = current_user.bookings.create(booking_params)

  #   respond_with @booking
  # end

  def show
    @booking = current_user.bookings.find params[:id]

    respond_with @booking
  end

  # private

  # def booking_params
  #   params.fetch(:booking, {}).permit(:event_id)
  # end
end
