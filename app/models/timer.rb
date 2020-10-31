# frozen_string_literal: true

# A timer wraps a model with the given timestamp attribute (default: expires_at)
#
# Example usage:
# timer = Timer.new(booking, attribute: :confirmation_expires_at)
# timer.set(10.minutes)
#
# Some time later
# do_something if timer.set? && timer.elapsed?
#
class Timer
  attr_reader :model, :attribute, :default_interval

  def initialize(model:, attribute: :expires_at, interval: nil, auto_set: false)
    @model = model
    @attribute = attribute
    @default_interval = interval
    set if auto_set
  end

  def set(interval: nil)
    interval ||= default_interval
    _set_value(interval.present? ? interval.from_now : nil)
  end

  def clear
    _set_value(nil)
  end

  def elapsed?
    return false unless set?

    Time.current > value
  end

  def set?
    value.present?
  end

  private

  def _set_value(value)
    model.send("#{attribute}=", value)
  end

  def value
    model.send(attribute)
  end
end
