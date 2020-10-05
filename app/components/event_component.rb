class EventComponent < ApplicationComponent
  include EventTiming
  include EventNaming

  attr_reader :event

  delegate :capacity, :bookings, :ballots, to: :event

  def initialize(event:, except: [], modifiers: {}, root_class: 'c-event', root_tag: :div)
    super(except: except, modifiers: modifiers, root_class: root_class, root_tag: root_tag)
    @event = event
  end

  def bookings_count
    @bookings_count ||= bookings.count
  end

  def ballot_overview
    render Ballots::OverviewComponent.new(ballot: last_ballot, except: :event)
  end

  def ballot_status
    render Ballots::StatusComponent.new(ballot: last_ballot)
  end

  private

  def last_ballot
    @ballot ||= ballots.last
  end
end
