module Bookings
  class AuthorizedToReinstateGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :reinstate
    end
  end
end
