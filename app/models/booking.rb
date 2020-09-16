class Booking < ApplicationRecord
  belongs_to :event
  belongs_to :user

  with_options class_name: 'User', optional: true do
    belongs_to :locked_by
    belongs_to :honoured_by
    belongs_to :made_by
  end

  enum aasm_state: {
    provisional: 1,
    confirmed: 2,
    cancelled: 3,
    deleted: 4
  }

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

    def honoured
      where.not(honoured_at: nil)
    end
  end
end
