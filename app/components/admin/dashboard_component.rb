module Admin
  class DashboardComponent < ApplicationComponent
    attr_reader :events, :event_count

    def initialize(events:, except: [])
      @events = events
      @event_count = events.count
    end
  end
end
