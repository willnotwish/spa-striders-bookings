module Ballots
  class StateMachineEventsComponent < ApplicationComponent
    # include StateMachine
    
    attr_reader :state_machine
    
    delegate :aasm, :open?, :closed?, :drawn?, to: :state_machine
    
    def initialize(ballot:, except: [])
      super(ballot: ballot, except: except)
      @state_machine = StateMachine.new(ballot)
    end

    # def aasm_event_names
    #   aasm.events.map(&:name)
    # end

    # def event_permitted?(event_name)
    #   return false unless aasm_event_names.include?(event_name)

    #   state_machine.send("may_#{event_name}?")
    # end

    # def url_for_event(name)
    #   [:new, :admin, ballot, name]
    # end

    def bulma_buttons
      aasm.events.collect do |aasm_event|
        event_name = aasm_event.name

        active = state_machine.send("may_#{event_name}?", current_user)
        url = [:new, :admin, ballot, event_name]

        modifier = active ? :is_primary : :is_light

        # debug "Button for: #{aasm_event.inspect}"
        button_options = {
          text: event_name.to_s.humanize,
          modifier: modifier,
          url: url,
          active: active
        }
        render Bulma::ButtonComponent.new(button_options)
      end.join(' ').html_safe
    end
  end
end
