# frozen_string_literal: true

# Intended to be used in regular user views (not admins or event admins).
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

  # Entry strategies:
  #
  # first come, first served (with or without waiting list)
  # via ballot

  def bookable_by_current_user?
    memoize :bookable_by_current_user do
      # An event is bookable iff
      #   it has space
      #   it's in the future
      #   it's published
      #   the current user does not already have a booking for it
      event.bookings.exists?(user: current_user)
    end
  end

  def enterable_by_current_user?
    memoize :enterable_by_current_user do
      # An event is enterable iff
      #   it has space
      #   it's in the future
      #   it's published
      #   the current user does not already have a booking for it
      event.bookings.exists?(user: current_user)
    end
  end

  def booked_by_current_user?
    memoize :booked_by_current_user do
      event.bookings.exists?(user: current_user)
    end
  end

  private

  def memoize(name)
    @memoized ||= []
    @memoized[name] = yield unless @memoized.key?(name)
  end

  def last_ballot
    @last_ballot ||= ballots.last
  end
end
