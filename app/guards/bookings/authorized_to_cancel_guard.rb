module Bookings
  class AuthorizedToCancelGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized_to? :cancel
    end
  end
end
