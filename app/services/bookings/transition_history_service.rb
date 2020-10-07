module Bookings
  class TransitionHistoryService
    attr_reader :booking, :source
    delegate :aasm, to: :booking

    def initialize(booking, source: nil, **)
      @booking = booking
      @source = source
    end

    def call
      booking.transitions.build(source: source,
                                from_state: aasm.from_state,
                                to_state: aasm.to_state)
    end
  end
end
