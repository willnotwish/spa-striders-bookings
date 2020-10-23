module Ballots
  class EventLockedGuard < ApplicationGuard
    delegate :event, to: :ballot

    def pass?
      event.locked?
    end
  end
end
