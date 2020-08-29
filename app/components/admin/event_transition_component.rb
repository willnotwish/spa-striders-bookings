module Admin
  class EventTransitionComponent < ApplicationComponent
    attr_reader :name, :event

    def initialize(name:, event:, modifier:)
      @name = name
      @event = event
      @modifier = modifier
    end

    def enabled?
      event.send "may_#{name}?"
    end

    def disabled?
      !enabled?
    end

    def html_class
      classes = %w[button]
      classes << @modifier if @modifier.present?
      classes.join(' ')
    end
  end
end
