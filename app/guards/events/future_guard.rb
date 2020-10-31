module Events
  class FutureGuard < ApplicationGuard
    include EventTiming

    def pass?
      event_not_started?
    end
  end
end
