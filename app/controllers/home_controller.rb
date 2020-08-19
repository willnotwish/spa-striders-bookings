class HomeController < ApplicationController
  respond_to :html
  
  def index
    @bookings = current_user.bookings.future.order(created_at: :asc)

    respond_with @bookings
  end
end
