# An event is cancellable by an admin at any time. Otherwise, 
# it needs to be in the future.

module Bookings
  module Guards
    class Cancellable < Base
      def call(source = nil, options = {})
        return true if admin_override?
        
        booking.future?        
      end
    end
  end
end
