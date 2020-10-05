module Ballots
  class OpenGuard < ApplicationGuard
    def call
      guard_against(:ballot_not_open) do
        ballot.opened?
      end
    end
  end
end
