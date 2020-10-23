module Ballots
  class AuthorizedToOpenGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized? :open
    end
  end
end
