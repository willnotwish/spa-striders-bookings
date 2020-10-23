module Ballots
  class AuthorizedToDrawGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :draw
    end
  end
end
