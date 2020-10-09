module Bookings
  class ApplicationGuard < ::ApplicationGuard
    def booking
      model
    end
  end
end
