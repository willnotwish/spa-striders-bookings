module EventHasSpace
  extend ActiveSupport::Concern

  delegate :capacity, to: :event, prefix: :event

  def event_has_space?
    return true if event_capacity.blank?

    event_spaces_taken_count < event_capacity
  end

  def event_spaces_left
    return nil if event_capacity.blank?
    
    spaces = event_capacity - event_spaces_taken_count
    spaces < 0 ? 0 : spaces
  end

  def event_full?
    !event_has_space?
  end

  def event_spaces_taken
    state = Booking.arel_table[:aasm_state]
    t0 = Booking.arel_table[:cancellation_cool_off_expires_at]
    not_timed_out = t0.eq(nil).or(t0.gt(Time.now))

    arel_predicate = state.eq('provisional')
      .or(state.eq('confirmed'))
      .or(state.eq('cancelled').and(not_timed_out))

    event.bookings.where(arel_predicate)
  end

  def event_spaces_taken_count
    event_spaces_taken.count
  end
end
