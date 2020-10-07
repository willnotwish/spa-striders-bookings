module Ballots
  class AuthorizedToDrawGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized? :draw
    end
  end
end
