class EventDecorator
  attr_reader :event

  include EventTiming

  def initialize(event)
    @event = event
  end
end
