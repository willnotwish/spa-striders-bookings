module Ballots
  class AuthorizedToCloseGuard < ApplicationGuard
    include PunditAuthorization

    def call
      guard_against(:not_authorized_to_close) do
        authorized? :close
      end
    end
  end
end
