class HomeController < ApplicationController
  respond_to :html
  
  def index
    @bookings = current_user.bookings.future.order(created_at: :asc)
    @events = Event.published.not_booked_by(current_user)

    respond_with @bookings
  end
end
