module Ballots
  class OpenGuard < ApplicationGuard
    def pass?
      ballot.opened?
    end
  end
end
