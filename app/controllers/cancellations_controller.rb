class CancellationsController < ApplicationController
  respond_to :html

  before_action :find_booking

  def new
    @cancellation = Cancellation.new(booking: @booking)
    respond_with @cancellation
  end

  def create
    @cancellation = Cancellation.create(booking: @booking)
    respond_with @cancellation, location: @booking
  end

  private

  def find_booking
    @booking = Booking.find params[:booking_id]
  end
end
