module Events
  class NotStartedGuard < ApplicationGuard
    include EventTiming

    delegate :event, to: :model

    def success?
      event_not_started?
    end
  end
end
