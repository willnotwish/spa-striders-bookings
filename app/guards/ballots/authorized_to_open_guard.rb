module Ballots
  class AuthorizedToOpenGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized? :open
    end
  end
end
