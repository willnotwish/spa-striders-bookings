# frozen_string_literal: true

# Bookings
class BookingsController < ApplicationController
  respond_to :html

  def index
    @bookings = base_scope
    respond_with @bookings
  end

  def show
    @booking = base_scope.find params[:id]
    respond_with @booking
  end

  private

  def base_scope
    policy_scope(Booking)
  end
end
