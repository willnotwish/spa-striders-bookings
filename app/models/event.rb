# frozen_string_literal: true

# For less popular events, users book directly via self-service. Confirmation
# is implicit: no further action on the part of the user is required.

# Admins may require users to "apply" to attend events likely
# to be oversubscribed.

# The process used to select successful applicants varies according
# to the event configuration, but may involve drawing entries
# at random (a ballot), or in the order the applications were submitted
# (first-come, first-served), or according to other criteria 
# such as performance (e.g., GFA), previous ballot entry failures,
# attendance record, reward points, etc.

# Successful applicants are each assigned a booking which may require
# confirmation.

# Regardless of how a user booking was created, a user is discouraged from
# turning up at an event without a confirmed booking.

# When the user attends the event in person, they are known as an "attendee";
# their booking is said to be "honoured".

# Users who decide to cancel their booking may do so. If the event in question
# is oversubscribed, the space freed by a booking cancellation may be taken
# by another event entrant automatically, subject to the rules of the event.
# For example, a ballot may be redrawn or a waiting list consulted.

# A cancellation may have a cooling-off period. During this time it may be
# reinstated with no side effects. (NOTE. This is experimental functionality;
# an alternative is to require confirmation at the time of cancellation.)
# A consequence of a cooling off period is that any automatic filling of a
# space left by a cancelled booking is delayed while the cancellation
# is in the pending state. The cooling-off period is likely to be hours
# rather than days.
class Event < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_exception

  with_options class_name: 'Booking', dependent: :restrict_with_exception do
    has_many :confirmed_bookings, -> { confirmed }
    has_many :cancelled_bookings, -> { cancelled }
    has_many :provisional_bookings, -> { provisional }
    has_many :provisional_or_confirmed_bookings, -> { provisional_or_confirmed }
    has_many :honoured_bookings, -> { honoured }
  end

  # TODO: consider renaming participant to booked_users (as previously),
  # Maybe this association could be removed altogether.
  has_many :participants, through: :bookings, source: :user

  has_many :attendees, through: :honoured_bookings, source: :user
  has_many :event_admins, dependent: :restrict_with_exception
  has_many :event_admin_users, through: :event_admins, source: :user
  has_many :transitions, class_name: 'Events::Transition'
  has_many :entries, autosave: true, class_name: 'Booking'
  has_many :entrants, through: :entries, source: :user

  # has_one :template, class_name: 'Events::Template'
  # An event may have a config. Configs are often shared between events
  belongs_to :config_data, class_name: 'Events::ConfigData', optional: true

  enum aasm_state: {
    draft: 10,
    published: 20,
    restricted: 30,
    locked: 40
  }

  include AASM
  aasm enum: true do
    state :draft, initial: true # no self-service bookings allowed; for setting up only
    state :published   # full access: self-service bookings allowed
    state :restricted  # allows cancellations but no new bookings or reinstatements
    state :locked      # allows neither cancellations nor reinstatements

    event :publish, guard: Events::AuthorizedToPublishGuard do
      transitions from: %i[draft restricted locked], 
                  to: :published
    end

    event :restrict do
      transitions from: %i[draft published locked], to: :restricted
    end

    event :lock, guard: Events::AuthorizedToLockGuard do
      transitions from: %i[draft published restricted], to: :locked
    end

    after_all_transitions StateTransitionBuilderService
  end

  validates :name, presence: true

  class << self
    def not_draft
      where.not(aasm_state: :draft)
    end
    alias_method :public, :not_draft

    def future
      where(arel_table[:starts_at].gt(Time.current))
    end
    alias_method :upcoming, :future

    def past
      where(arel_table[:starts_at].lt(Time.current))
    end

    def within(period)
      where(arel_table[:starts_at].lt(period.from_now))
    end

    def not_booked_by(user)
      booking_scope = Booking.where.not(user: user)
                             .or(Booking.where(user: nil))
      left_outer_joins(:bookings).merge(booking_scope)
    end

    def with_no_confirmed_bookings
      left_outer_joins(:confirmed_bookings).where('bookings.id IS NULL')
    end

    def with_no_provisional_or_confirmed_bookings
      left_outer_joins(:provisional_or_confirmed_bookings)
        .where('bookings.id IS NULL')
    end

    def with_space
      # To be rewritten without the SQL fragments
      left_outer_joins(:provisional_or_confirmed_bookings)
        .group('events.id, events.capacity')
        .having('count(bookings.id) < events.capacity')
    end
  end
end
