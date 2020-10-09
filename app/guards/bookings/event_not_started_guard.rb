module Bookings
  class EventNotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :booking

    def success?
      event_not_started?
    end
  end
end
