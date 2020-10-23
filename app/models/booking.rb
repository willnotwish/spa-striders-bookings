class Booking < ApplicationRecord
  belongs_to :event
  belongs_to :user

  with_options class_name: 'User', optional: true do
    belongs_to :locked_by
    belongs_to :honoured_by
    belongs_to :made_by
  end

  has_many :transitions, class_name: 'Bookings::Transition'

  include AASM
  aasm enum: true do
    state :provisional, initial: true
    state :confirmed, after_enter: -> { self.expires_at = nil }
    state :cancelled

    event :confirm, guard: Bookings::AuthorizedToConfirmGuard do
      transitions from: :provisional, to: :confirmed
    end

    event :cancel, after_enter: Bookings::StartCancellationCoolOff do
      transitions from:  %i[provisional confirmed], 
                  to:    :cancelled,
                  guard: Bookings::AuthorizedToCancelGuard
    end

    event :reinstate do
      transitions from: :cancelled, to: :confirmed,
                  guard: Bookings::AuthorizedToReinstateGuard
    end

    after_all_transitions StateTransitionBuilderService
  end

  enum aasm_state: {
    provisional: 1,
    confirmed: 2,
    cancelled: 3
  }

  class << self
    def future
      joins(:event).merge Event.future
    end

    def past
      joins(:event).merge Event.past
    end

    def within(period)
      joins(:event).merge Event.within(period)
    end

    def honoured
      where.not(honoured_at: nil)
    end

    def provisional_or_confirmed
      where(aasm_state: :provisional).or(where(aasm_state: :confirmed))
    end
  end
end
