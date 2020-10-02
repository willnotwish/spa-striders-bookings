module Ballots
  module BallotEventProgress
    def event_not_started?(event)
      !event_started?(event)
    end

    def event_started?(event)
      Time.now >= event.starts_at
    end
  end
end
