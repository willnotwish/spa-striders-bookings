module Ballots
  class AuthorizedToCloseGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :close
    end
  end
end
