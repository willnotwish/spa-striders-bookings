module Ballots
  class AuthorizedToCloseGuard < ApplicationGuard
    include PunditAuthorization

    attr_reader :user

    def success?
      authorized? :close
    end
  end
end
