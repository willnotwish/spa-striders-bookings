class Booking < ApplicationRecord
  belongs_to :event
  belongs_to :user

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
end
