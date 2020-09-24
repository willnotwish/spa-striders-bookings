module Bookings
  class Cancellation
    include HasStatefulBooking

    validate :check_guard

    def save
      return false if invalid?
      
      stateful_booking.cancel
    end

    private

    def check_guard
      return unless booking # just like an EachValidator. Long story...

      guard = Guards::Cancellable.new(stateful_booking)
      unless guard.call
        @errors[:booking] << "cannot be cancelled at this time"
      end
    end
  end
end
