module Bookings
  class EventHasSpaceGuard < ApplicationGuard
    include EventHasSpace
    delegate :event, to: :booking

    def success?
      event_has_space?
    end
  end
end