class BookingStateComponent < ApplicationComponent
  attr_reader :state

  def initialize(state:)
    @state = state
  end

  def html_class
    "tag #{bulma_modifier}"
  end

  def text
    state.humanize
  end

  def bulma_modifier
    case state.to_s
    when 'confirmed'
      'is-success'
    when 'provisional'
      'is-warning'
    else
      'is-dark'
    end
  end
end
