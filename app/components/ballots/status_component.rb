module Ballots
  class StatusComponent < ApplicationComponent
    # include StateMachine

    attr_reader :state_machine
    
    delegate :aasm, :open?, :closed?, :drawn?, to: :state_machine
    
    def initialize(ballot:, except: [])
      super(ballot: ballot, except: except)
      @state_machine = StateMachine.new(ballot)
    end

    def status
      aasm.human_state
    end

    def status_badge
      render Bulma::TagComponent.new(text: aasm.human_state, modifier: bulma_modifier)
    end

    BULMA_MAP = {
      open:   :warn,
      closed: :dark,
      drawn:  :success
    }

    def bulma_modifier
      BULMA_MAP.fetch(aasm.current_state, :dark)
    end
  end
end
