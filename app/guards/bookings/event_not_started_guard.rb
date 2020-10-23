module Bookings
  class EventNotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :booking

    def pass?
      event_not_started?
    end
  end
end
