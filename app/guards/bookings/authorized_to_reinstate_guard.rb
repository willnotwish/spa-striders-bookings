module Bookings
  class AuthorizedToReinstateGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized_to? :reinstate
    end
  end
end
