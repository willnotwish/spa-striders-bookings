module EventHasSpace
  extend ActiveSupport::Concern

  def event_has_space?
    return true if event.capacity.blank?

    event.provisional_or_confirmed_bookings.count < event.capacity
  end

  def event_full?
    !event_has_space?
  end
end
