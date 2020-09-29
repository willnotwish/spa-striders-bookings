module Ballots
  class StateMachine
    include AASM

    attr_accessor :ballot

    COMMON_GUARDS = %i[permitted_user? event_not_started?]

    aasm do
      state :closed, initial: true
      state :opened
      state :drawn

      event :open, guard: COMMON_GUARDS do
        transitions from: :closed, to: :opened
      end

      event :close, guard: COMMON_GUARDS do
        transitions from: :opened, to: :closed
      end

      event :draw, guard: COMMON_GUARDS + %i[event_locked? no_duplicate_entries?] do
        transitions from:  :closed, 
                    to:    :drawn, 
                    after: :process_ballot_entries
      end

      after_all_events :persist_changes!
    end

    def initialize(ballot)
      @ballot = ballot
      @processed_entries = []
      aasm.current_state = ballot.aasm_state.to_sym
    end

    private

    delegate :event, :ballot_entries, :logger, to: :ballot
    # delegate :starts_at, to: :event, prefix: :event
  
    # Before/after callbacks
    def persist_changes!
      Ballot.transaction do
        @processed_entries.each { |entry| entry.save! }
        ballot.update! aasm_state: aasm.to_state
      end
    end

    def process_ballot_entries
      max_bookings = event.capacity - event.bookings.provisional_or_confirmed.count      
      unprocessed_entries = ballot_entries.to_a
      existing_booked_user_ids = event.bookings.pluck(:user_id)
      @processed_entries.clear
      new_bookings_count = 0
      while(new_bookings_count < max_bookings && unprocessed_entries.length > 0)
        entry = unprocessed_entries.sample

        @processed_entries << entry
        unprocessed_entries.delete(entry)
        
        # Ignore entry if the user already has a booking
        next if existing_booked_user_ids.include?(entry.user.id)

        booking = entry.build_booking(event: event, user: entry.user, aasm_state: :provisional)
        new_bookings_count += 1
      end
    end

    # Guards
    
    def no_duplicate_entries?(current_user = nil)
      user_ids = ballot_entries.pluck(:user_id)
      user_ids.uniq.length == user_ids.length
    end

    def event_not_started?(current_user = nil)
      Time.now < event.starts_at
    end

    def permitted_user?(current_user = nil)
      current_user&.admin?
    end

    def event_locked?(current_user = nil)
      event.locked?      
    end
  end
end
