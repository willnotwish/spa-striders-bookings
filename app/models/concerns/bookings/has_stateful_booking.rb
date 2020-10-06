module Bookings
  module HasStatefulBooking
    extend ActiveSupport::Concern
    include ActiveModel::Model

    included do
      attr_accessor :booking
      validates :booking, presence: true
      delegate :user, :event, to: :booking, allow_nil: true
    end

    private

    def stateful_booking
      @stateful_booking ||= StatefulBooking.new(booking)
    end

    class_methods do
      def create(attrs)
        new(attrs).tap { |instance| instance.save }      
      end
    end
  end
end
