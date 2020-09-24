# A booking is confirmable by an admin at any time. Otherwise, 
# it must not have expired.

module Bookings
  module Guards
    class Confirmable < Base
      def call
        return true if admin_override?               
        return true if booking.expires_at.blank?

        Time.now < booking.expires_at
      end
    end
  end
end
