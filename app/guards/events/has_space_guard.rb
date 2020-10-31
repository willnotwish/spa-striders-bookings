module Events
  class HasSpaceGuard < ApplicationGuard
    include EventHasSpace

    def pass?
      event_has_space?
    end
  end
end
