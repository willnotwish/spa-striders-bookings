class Event < ApplicationRecord
    enum aasm_state: {
        draft: 1,
        published: 2,
        restricted: 3,
        deleted: 4 
    }
    
    include AASM
    aasm do
        state :draft, initial: true
        state :published
        state :restricted
        state :deleted

        event :publish do
            transitions to: :published
        end
    end

    has_many :bookings
    has_many :users, through: :bookings

    validates :name, presence: true

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
    end
end
