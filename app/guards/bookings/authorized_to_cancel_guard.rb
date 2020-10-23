module Bookings
  class AuthorizedToCancelGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :cancel
    end
  end
end
