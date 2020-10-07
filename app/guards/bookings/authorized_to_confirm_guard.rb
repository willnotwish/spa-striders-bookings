module Bookings
  class AuthorizedToConfirmGuard < ApplicationGuard
    include PunditAuthorization

    def success?
      authorized? :confirm
    end
  end
end
