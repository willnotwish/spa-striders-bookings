# frozen_string_literal: true

# Includes no user decoration since this
# component is intended only to be used
# by non-namespaced, member-facing views.
class BookingComponent < ApplicationComponent
  include EventTiming

  attr_reader :booking

  delegate :event, :confirmed?, :cancelled?, :aasm_state, to: :booking
  delegate :name, :description, to: :event, prefix: :event

  def initialize(booking:, except: [], modifiers: {}, root_class: 'c-booking', root_tag: :div)
    super(except: except, modifiers: modifiers, root_class: root_class, root_tag: root_tag)
    @booking = booking
  end

  def state
    aasm_state
  end
end
