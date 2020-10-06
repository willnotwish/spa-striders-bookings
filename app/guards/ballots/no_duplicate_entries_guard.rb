module Ballots
  class NoDuplicateEntriesGuard < ApplicationGuard
    delegate :ballot_entries, to: :ballot

    def success?
      ids = ballot_entries.pluck(:user_id)
      ids.uniq.length == ids.length
    end
  end
end
