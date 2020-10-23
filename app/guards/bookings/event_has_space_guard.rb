module Bookings
  class EventHasSpaceGuard < ApplicationGuard
    include EventHasSpace
    delegate :event, to: :booking

    def pass?
      event_has_space?
    end
  end
end