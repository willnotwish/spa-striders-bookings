module Ballots
  class AuthorizedToOpenGuard < ApplicationGuard
    include PunditAuthorization

    def call
      guard_against(:not_authorized_to_open) do
        authorized? :open
      end
    end
  end
end
