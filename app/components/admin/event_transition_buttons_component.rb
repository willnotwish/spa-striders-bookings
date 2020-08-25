module Admin
  class EventTransitionButtonsComponent < ApplicationComponent
    attr_reader :event

    def initialize(event:)
      @event = event
    end

    def button_modifier(transition)
      case transition
      when :publish
        'is-danger'
      when :restrict
        'is-warning'
      when :lock
        'is-dark'
      else
        'is-light'
      end
    end
  end
end
