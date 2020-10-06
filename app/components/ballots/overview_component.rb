module Ballots
  class OverviewComponent < ApplicationComponent
    # include EventNaming
    # include TimingMethods

    with_collection_parameter :ballot

    # attr_reader :ballot

    # delegate :event,
    #          :description,
    #          :ballot_entries,
    #          :opens_at,
    #          :closes_at, to: :ballot

    # delegate :starts_at, to: :event, prefix: :event

    # declare_timing_methods :opens_at, :closes_at, :event_starts_at

    def initialize(ballot:, root_tag: :ul, root_class: 'c-ballot-overview', except: [])
      super(ballot: ballot, root_tag: root_tag, root_class: root_class, except: except)
      # @ballot = ballot
    end

    # def entry_count
    #   ballot_entries.size
    # end
  end
end
