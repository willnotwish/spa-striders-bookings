module Ballots
  class AuthorizedToDrawGuard < ApplicationGuard
    include PunditAuthorization

    attr_reader :user

    def initialize(ballot, user:, guard_failures_collector: nil, **opts)
      super(ballot, guard_failures_collector: guard_failures_collector)
     
      @user = user
    end

    def call
      guard_against(:not_authorized_to_draw) do
        authorized? :draw
      end
    end
  end
end
