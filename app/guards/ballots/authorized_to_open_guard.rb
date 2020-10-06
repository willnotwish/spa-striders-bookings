module Ballots
  class AuthorizedToOpenGuard < ApplicationGuard
    include PunditAuthorization

    attr_reader :user

    def initialize(ballot, user:, **)
      super
      @user = user
    end

    def success?
      authorized? :open
    end
  end
end
