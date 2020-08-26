class EventComponent < ApplicationComponent
  attr_reader :event,
              :title,
              :date,
              :time,
              :state,
              :capacity,
              :bookings

  def initialize(event:)
    @event = event
    @title = event.name
    @date = I18n.l(event.starts_at, format: :date)
    @time = I18n.l(event.starts_at, format: :hm)
    @state = event.aasm_state
    @capacity = event.capacity || 'unlimited'
    @bookings = event.confirmed_bookings
  end

  def bookings_count
    @bookings_count ||= event.confirmed_bookings.count
  end

  def booking_progress
    "#{bookings_count} of #{capacity} bookings"
  end
  alias_method :progress, :booking_progress

  def root_class
    'event'
  end
end
