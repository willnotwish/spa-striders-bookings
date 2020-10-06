module Ballots
  class AuthorizedToDrawGuard < ApplicationGuard
    include PunditAuthorization

    attr_reader :user

    def initialize(ballot, user:, **) 
      super
      @user = user
    end

    def success?
      authorized? :draw
    end
  end
end
