# If the number of entries becomes large, this approach will be slow
# and use a lot of memory. It's OK for now though.

class BuildBookingsFromEventEntriesService < ApplicationService
  include EventHasSpace

  # Relates to an event
  alias_method :event, :model

  attr_reader :selection_strategy,   # random, fifo or custom (#call)
              :booking_type,         # provisional or confirmed (default: provisional)
              :confirmation_period,  # default: 24.hours
              :bookings_collector    # default: nil (no collector)

  delegate :participants, :entries, :unsuccessful_entries, to: :event

  def initialize(event, selection_strategy: :random,
                        booking_type: :provisional,
                        confirmation_period: 24.hours, 
                        bookings_collector: nil, **)
    super    
    @selection_strategy = selection_strategy
    @booking_type = booking_type
    @confirmation_period = confirmation_period
    @bookings_collector = bookings_collector
  end

  def call
    candidate_entries = entries.where(booking: nil)
                               .order(created_at: :asc)
                               .to_a
    return if candidate_entries.empty?

    max_bookings = event_spaces_left
    return unless max_bookings > 0

    count = 0
    while(count < max_bookings && candidate_entries.present?)
      selected_entry = select_entry_from_list(candidate_entries)
      next unless selected_entry

      user = selected_entry.user
      candidate_entries.delete(selected_entry) # don't select it again
      next if participants.include?(user)

      booking_attrs = {
        event: event,
        user: user,
        aasm_state: booking_type
      }

      if booking_type == :provisional
        booking_attrs[:expires_at] = confirmation_period.from_now
      end

      # Build a new booking "in place" so that AR knows it's part of the 
      # event. If we don't do this, AR won't auto save the bookings when
      # we save the event later.

      # This is a bit messy. Should be refactored.
      # Other ways might work better.
      index = entries.index(selected_entry)          
      entries[index].build_booking(booking_attrs) do |booking|
        bookings_collector << booking if bookings_collector
      end
      count += 1
    end  
  end

  private

  def select_entry_from_list(list)
    case selection_strategy
    when :random
      list.sample      
    when :first_come_first_served, :fifo
      list.first
    else
      selection_strategy.call(list) if selection_strategy&.respond_to?(:call)
    end
  end
end
