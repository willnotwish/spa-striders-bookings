module Ballots
  class AuthorizedToCloseGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized_to? :close
    end
  end
end
