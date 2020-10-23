module Bookings
  class AuthorizedToConfirmGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized? :confirm
    end
  end
end
