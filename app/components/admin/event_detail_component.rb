module Admin
  class EventDetailComponent < EventComponent
    # attr_reader :event,
    #             :title,
    #             :date,
    #             :time,
    #             :state,
    #             :bookings_count,
    #             :capacity
  
    # def initialize(event:)
    #   @event = event
    #   @title = event.name
    #   @date = I18n.l(event.starts_at, format: :date)
    #   @time = I18n.l(event.starts_at, format: :hm)
    #   @bookings_count = event.confirmed_bookings.count
    #   @state = event.aasm_state
    #   @capacity = event.capacity || 'unlimited'
    # end

    # def booking_progress
    #   "#{bookings_count} of #{capacity} bookings"
    # end
    # alias_method :progress, :booking_progress

    def root_class
      'admin-event-detail'
    end
  end
end
