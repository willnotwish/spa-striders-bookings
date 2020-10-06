module Ballots
  module PunditAuthorization
    def authorized?(event_name)
      policy = Pundit.policy(user, ballot)
      policy&.send("#{event_name}?")
    end
  end
end
