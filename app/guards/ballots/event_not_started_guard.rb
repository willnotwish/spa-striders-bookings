module Ballots
  class EventNotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :ballot

    def call
      guard_against(:event_already_started) do
        event_not_started?
      end
    end
  end
end
