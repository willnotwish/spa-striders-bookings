class Event < ApplicationRecord
  has_many :bookings
  has_many :booked_users, through: :bookings, source: :user

  with_options class_name: 'Booking' do
    has_many :confirmed_bookings, -> { confirmed }
    has_many :provisional_or_confirmed_bookings, -> { provisional_or_confirmed }
    has_many :honoured_bookings, -> { honoured }
  end

  has_one :ballot
  # has_one :waiting_list

  has_many :event_admins
  has_many :event_admin_users, through: :event_admins, source: :user

  has_many :transitions, class_name: 'Events::Transition'
  
  enum aasm_state: {
    draft:      10,
    published:  20,
    restricted: 30,
    locked:     40
  }
  
  include AASM  
  aasm enum: true do
    state :draft, initial: true # no bookings allowed
    state :published   # full access by everyone
    state :restricted  # allows cancellations but no new bookings or reinstatements
    state :locked      # allows neither cancellations nor reinstatements

    event :publish do
      transitions from: %i[draft restricted locked], to: :published
    end

    event :restrict do
      transitions from: %i[draft published locked], to: :restricted
    end

    event :lock do
      transitions from: %i[draft published restricted], to: :locked
    end
  end

  validates :name, presence: true

  class << self
    def future
      where(arel_table[:starts_at].gt(Time.now))
    end
    alias_method :upcoming, :future

    def past
      where(arel_table[:starts_at].lt(Time.now))
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
