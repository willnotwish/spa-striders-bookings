module Ballots
  class StatusComponent < ApplicationComponent
    attr_reader :ballot
    
    delegate :aasm_state, :open?, :closed?, :drawn?, to: :ballot
    
    def initialize(ballot:, except: [])
      super(ballot: ballot, except: except)
      @ballot = ballot
    end

    def status_text
      case aasm_state
      when 'opened'
        'Ballot open'
      when 'closed'
        'Ballot closed'
      else 'drawn'
        'Ballot drawn'
      end
    end

    def status_badge
      render Bulma::TagComponent.new(text: status_text, modifier: bulma_modifier)
    end

    BULMA_MAP = {
      opened: :success,
      closed: :dark,
      drawn:  :success
    }

    def bulma_modifier
      BULMA_MAP.fetch(aasm_state.to_sym, :dark)
    end
  end
end
