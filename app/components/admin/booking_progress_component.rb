class Admin::BookingProgressComponent < ApplicationComponent
  attr_reader :event

  delegate :confirmed_bookings, :capacity, to: :event

  def initialize(event:)
    @event = event
  end

  def text
    base = "#{confirmed_bookings.count} / #{capacity}"
    if capacity.present? && capacity > 0
      base += " (#{percent.to_i}% full)"
    end
    base
  end

  def percent
    (100.0 * confirmed_bookings.count) / capacity
  end

  def capacity_as_text
    'Capacity as text TBD'
  end
end
