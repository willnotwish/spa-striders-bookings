module Ballots
  module HasSpace
    def ballot_has_space?
      return false unless ballot
      return true if ballot.size.blank?
      
      ballot.ballot_entries.count < ballot.size
    end
  end
end
