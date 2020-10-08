module BookingOperation
  extend ActiveSupport::Concern
  include ActiveModel::Model
  
  included do
    attr_accessor :user, :event_id

    validates :user, :event_id, presence: true  

    # Experimental
    # validates :user, uniqueness: { scope: :event }
    validate :not_already_booked

  end

  def event
    return nil unless event_id.present?

    @event ||= Event.find(event_id)
  end

private
  
  def booking
    @booking ||= build_booking
  end

  def build_booking
    ::Booking.new(user: user, event_id: event_id, aasm_state: :provisional)
  end

  def not_already_booked
    return unless user && event
  
    if user.events.include?(event)
      @errors[:user] << 'already has a booking for this event'
    end
  end
end
