module Ballots
  class ApplicationGuard < ::ApplicationGuard
    def ballot
      model
    end
  end
end
