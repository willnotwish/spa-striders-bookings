# This service, if the auto_replace option is truthy, calls the
# BuildEventBookingsService to replace the cancelled booking with
# another from the event's entries. If auto_replace is falsey, it does nothing.

module Bookings
  class BookingReplacementService < ApplicationService
    alias_method :booking, :model
    
    attr_reader :auto_replace, :options
    delegate :event, to: :booking

    def initialize(booking, auto_replace: false, **options)
      super
      @booking = booking
      @auto_replace = auto_replace
      @options = options
    end

    def call
      return unless auto_replace
      
      BuildBookingsFromEventEntriesService.call(event, options)
    end
  end  
end
