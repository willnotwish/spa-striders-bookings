# frozen_string_literal: true

# Event space calculation.
#
# An event has space if the number of bookings that "take space" is less than
# its capacity. For a booking to "take space" it must be
#   * confirmed, or
#   * provisional with the confirmation timer still running, or
#   * cancelled with the cancellation timer still running.
#
# Recall that, following cancellation of a provisional or confirmed booking,
# a cancellation timer is started. Its purpose is to allow a user to change
# their mind about cancellation, or to undo a mistaken cancellation
# which might cause them to lose their place.
#
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
    spaces.negative? ? 0 : spaces
  end

  def event_full?
    !event_has_space?
  end

  def event_spaces_taken
    state = Booking.arel_table[:aasm_state]
    predicate = state.eq('confirmed')
                     .or(state.eq('provisional')
                              .and(timing_predicate(:confirmation_timer_expires_at)))
                     .or(state.eq('cancelled')
                              .and(timing_predicate(:cancellation_timer_expires_at)))
    event.bookings.where(predicate)
  end

  delegate :count, to: :event_spaces_taken, prefix: :event_spaces_taken

  private

  def timing_predicate(arel_attr_name)
    t0 = Booking.arel_table[arel_attr_name]
    t0.eq(nil).or(t0.gt(Time.current))
  end
end
