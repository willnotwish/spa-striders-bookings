module Admin
  class EventComponent < ApplicationComponent
    # include StartsAtTiming

    attr_reader :event

    delegate :bookings, :name, :starts_at, :capacity, to: :event

    def initialize(event:, except: [], only: [], root_class: 'admin-event', root_tag: :div)
      super(except: except, only: only, root_class: root_class, root_tag: root_tag)
      @event = event
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
