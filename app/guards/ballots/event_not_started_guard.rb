module Ballots
  class EventNotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :ballot

    def success?
      event_not_started?
    end
  end
end
