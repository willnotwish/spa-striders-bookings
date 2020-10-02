module Ballots
  class AuthorizedToDrawGuard < ApplicationGuard
    include PunditAuthorization

    def call
      guard_against(:not_authorized_to_draw) do
        authorized? :draw
      end
    end
  end
end
