module Ballots
  class NoDuplicateEntriesGuard < ApplicationGuard
    delegate :ballot_entries, to: :ballot

    def call
      guard_against(:duplicate_ballot_entries) do
        ids = ballot_entries.pluck(:user_id)
        ids.uniq.length == ids.length
      end
    end
  end
end
