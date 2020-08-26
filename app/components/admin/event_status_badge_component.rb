module Admin 
  class EventStatusBadgeComponent < ApplicationComponent
    attr_reader :text, :bulma_modifier

    def initialize(event:)
      @event = event
      @text = event.aasm.human_state
      @bulma_modifier = 
        case event.aasm.current_state
        when :published
          'is-success'
        when :restricted
          'is-warning'
        when :locked
          'is-dark'
        end
    end

    def html_class
      "tag #{bulma_modifier}"
    end
  end
end
