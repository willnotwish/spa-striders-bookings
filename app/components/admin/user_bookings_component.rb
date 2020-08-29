module Admin
  class UserBookingsComponent < ApplicationComponent
    attr_reader :bookings, 
                :confirmed_future_bookings_count,
                :confirmed_past_bookings_count
  
    def initialize(bookings:)
      @bookings = bookings
      @confirmed_future_bookings_count = bookings.confirmed.future.count
      @confirmed_past_bookings_count = bookings.confirmed.past.count
    end

    def confirmed_bookings
      bookings.confirmed
    end
  end
end
