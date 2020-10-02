module Ballots
  class EventLockedGuard < ApplicationGuard
    delegate :event, to: :ballot

    def call
      guard_against(:event_not_locked) do
        event.locked?
      end
    end
  end
end
