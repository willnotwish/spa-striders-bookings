module Admin
  class BookingProgressComponent < ApplicationComponent
    attr_reader :event

    delegate :confirmed_bookings, :capacity, to: :event

    def initialize(event:, root_class: 'c-booking-progress', except: [])
      super(root_class: root_class, except: except)
      @event = event
    end

    def booking_count
      @booking_count ||= confirmed_bookings.count
    end

    def proportion
      "#{booking_count} / #{capacity}"
    end

    def percent_full
      "#{percent.to_i}% full"
    end

    def full?
      booking_count == capacity
    end

    def empty?
      booking_count == 0
    end

    def badge
      if full?
        content_tag :span, 'Full', class: 'tag is-danger'
      elsif empty?
        content_tag :span, 'Empty', class: 'tag is-warning'
      end
    end

    def text
      base = "#{booking_count} / #{capacity}"
      if capacity.present? && capacity > 0
        base += " (#{percent.to_i}% full)"
      end
      base
    end

    def percent
      (100.0 * booking_count) / capacity
    end

    def capacity_as_text
      'Capacity as text TBD'
    end
  end
end
