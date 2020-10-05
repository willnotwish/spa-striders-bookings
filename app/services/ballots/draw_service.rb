module Ballots
  class DrawService
    attr_reader :options, :ballot

    delegate :event, to: :ballot
    delegate :booked_users, to: :event

    def initialize(*args)
      @options = args.extract_options!
      @ballot = args[0]

      raise 'Ballot must be specified as first argument' unless @ballot
    end

    def booking_type
      options.fetch(:booking_type, :provisional)
    end

    def confirmation_period
      options.fetch(:confirmation_period, 24.hours)
    end

    def bookings_collector
      options[:bookings_collector]
    end

    def call
      candidate_entries = ballot.ballot_entries.to_a
      return if candidate_entries.empty?
      
      max_bookings =
        event.capacity - event.bookings.provisional_or_confirmed.count
      
      return unless max_bookings > 0
      
      bookings_made = 0
      while(bookings_made < max_bookings && candidate_entries.present?)

        # Draw an entry at random
        drawn_entry = candidate_entries.sample
        drawn_user = drawn_entry.user
        
        # Remove it so we don't draw it again
        candidate_entries.delete(drawn_entry)
        
        # Ignore if the drawn user already has a booking
        next if booked_users.include?(drawn_user)

        booking_attrs = {
          event: event,
          user: drawn_user,
          aasm_state: booking_type
        }

        if booking_type == :provisional
          booking_attrs[:expires_at] = confirmation_period.from_now
        end

        # Build a new booking "in place" so that AR knows it's part of the 
        # ballot. If we don't do this, we can't auto save the bookings when
        # we save the ballot later.

        # This is a bit messy. Should be refactored...
        index = ballot.ballot_entries.to_a.index(drawn_entry)
                  
        booking = ballot.ballot_entries[index].build_booking booking_attrs
        notify_new_booking(booking)

        bookings_made += 1
      end  
    end

    def notify_new_booking(booking)
      if bookings_collector
        bookings_collector << booking
      end
    end
  end
end
