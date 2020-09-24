module Bookings
  class Confirmation
    include HasStatefulBooking

    validate :check_guard

    def save
      return false if invalid?
      
      stateful_booking.confirm
    end

    private

    def check_guard
      return unless booking # just like an EachValidator. Long story...

      guard = Guards::Confirmable.new(stateful_booking)
      unless guard.call
        @errors[:booking] << "cannot be confirmed at this time"
      end
    end
  end
end
