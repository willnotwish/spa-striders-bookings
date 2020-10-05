module Ballots
  class StateMachine
    include AASM

    # attr_reader :ballot, :pending_notifications

    aasm do
      state :closed, initial: true
      state :opened
      state :drawn

      event :open, guard: [AuthorizedToOpenGuard, EventNotStartedGuard] do
        transitions from: :closed, to: :opened
      end

      event :close, guard: AuthorizedToCloseGuard do
        transitions from: :opened, to: :closed
      end

      event :draw, guard: [AuthorizedToDrawGuard,
                           EventNotStartedGuard,
                           EventLockedGuard,
                           NoDuplicateEntriesGuard] do
        transitions from:  :closed, 
                    to:    :drawn, 
                    after: DrawService
      end

      # after_all_events :persist_ballot!, :enqueue_pending_notifications!
    end

    def initialize(state)
      # @ballot = ballot
      aasm.current_state = state.to_sym
      # @pending_notifications = []
    end

    # def initialize(ballot)
    #   @ballot = ballot
    #   aasm.current_state = ballot.aasm_state.to_sym
    #   # @pending_notifications = []
    # end

    # private

    # # Before/after callbacks
    # def persist_ballot!
    #   # Saves not only the ballot status but also any new bookings and
    #   # updated ballot entries
    #   ballot.update! aasm_state: aasm.to_state
    # end

    # def enqueue_pending_notifications!
    #   pending_notifications.each(&:deliver_later)
    #   pending_notifications.clear
    # end
  end
end
