# A booking is confirmable by an admin at any time. Otherwise, 
# it must not have expired.

module Bookings
  module Guards
    class Base
      attr_reader :parent, :source, :options

      delegate :booking, to: :parent
      delegate :logger, to: :booking

      def initialize(parent, source = nil, options = {})
        @parent = parent
        @source = source
        @options = options
      end

      def admin_override?
        return false unless source
        
        source.respond_to?(:admin?) && source.admin?
      end
    end
  end
end
