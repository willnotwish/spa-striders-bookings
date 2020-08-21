class Event < ApplicationRecord
  has_many :bookings
  has_many :confirmed_bookings, -> { confirmed }, class_name: 'Booking'

  enum aasm_state: {
    draft: 1,
    published: 2,
    restricted: 3,
    deleted: 4 
  }
  
  include AASM  
  aasm do
    state :draft, initial: true
    state :restricted
    state :published
    state :deleted

    event :publish do
      transitions to: :published
    end
  end

  validates :name, presence: true

  def has_space?
    !full?
  end

  def full?
    return false if capacity.blank?

    confirmed_bookings.count >= capacity
  end

  def future?
    starts_at > Time.now
  end

  def past?
    !future?
  end

  class << self
    def future
      where(arel_table[:starts_at].gt(Time.now))
    end

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

    def with_space
      # To be rewritten without the SQL fragments
      left_outer_joins(:confirmed_bookings)
        .group('events.id, events.capacity')
        .having('count(bookings.id) < events.capacity')
    end
  end
end
