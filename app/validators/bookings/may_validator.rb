module Bookings
  class MayValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, booking)
      return unless booking
  
      event = options[:event]
      stateful_booking = StatefulBooking.new(booking)
      unless stateful_booking.send("may_#{event}?")
        record.errors[attribute] << (options[:message] || "may not #{event} at this time")
      end
    end
  end
end
