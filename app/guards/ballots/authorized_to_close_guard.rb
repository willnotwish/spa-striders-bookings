module Ballots
  class AuthorizedToCloseGuard < ApplicationGuard
    include PunditAuthorization

    attr_reader :user

    def initialize(ballot, user:, **)
      super 
      @user = user
    end

    def success?
      authorized? :close
    end
  end
end
