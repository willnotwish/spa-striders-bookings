module Ballots
  class EventNotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :ballot

    def pass?
      event_not_started?
    end
  end
end
