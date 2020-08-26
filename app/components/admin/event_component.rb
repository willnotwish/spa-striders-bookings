module Admin
  class EventComponent < ApplicationComponent
    attr_reader :event

    delegate :bookings, :name, :starts_at, :capacity, to: :event

    def initialize(event:, except: [], only: [])
      @event = event
      @except = except.respond_to?(:each) ? except : [except]
      @only = only
    end

    def show_bookings?
      show?(:bookings)
    end

    def date
      I18n.l(starts_at, format: :date)
    end

    def time
      I18n.l(starts_at, format: :hm)
    end
  end
end
