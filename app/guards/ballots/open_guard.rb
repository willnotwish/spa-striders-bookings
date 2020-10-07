module Ballots
  class OpenGuard < ApplicationGuard
    def success?
      ballot.opened?
    end
  end
end
