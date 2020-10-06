module Ballots
  class EventLockedGuard < ApplicationGuard
    delegate :event, to: :ballot

    # The definition of success
    def success?
      event.locked?
    end
  end
end
