module Bookings
  class EventHasSpaceGuard < ApplicationGuard
    delegate :event, to: :booking

    def success?
      event.has_space?
    end
  end
end