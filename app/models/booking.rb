class Booking < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum aasm_state: {
    confirmed: 2,
    cancelled: 3,
    deleted: 4
  }

  include AASM
  aasm do
    state :confirmed, initial: true
    state :cancelled

    event :cancel do
      transitions from: :confirmed, to: :cancelled, guard: :future?
    end

    event :reinstate do
      transitions from: :cancelled,
                  to: :confirmed, 
                  guard: [:event_has_space?, :future?]
    end
  end

  validates :event, uniqueness: { scope: :user },
                    has_space: true,
                    future: true,
                    on: :create

  delegate :future?, :past?, to: :event

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
  end

  private

  def event_has_space?
    event.has_space?
  end

  def check_event_is_not_full
    return unless event

    @errors[:event] << "is full" unless event_has_space?
  end

  def check_event_is_in_the_future
    return unless event

    @errors[:event] << "has already happened" unless future?
  end
end
