module Ballots
  class ApplicationGuard
    attr_reader :ballot, :guard_failures_collector

    def initialize(ballot, guard_failures_collector: nil, **opts)
      raise 'Ballot must be specified as first argument' unless ballot.present?

      @ballot = ballot
      @guard_failures_collector = guard_failures_collector
    end

    private

    def guard_against(failure, &block)
      raise 'No block supplied' unless block_given?
      return true if yield

      guard_failures_collector&.call(failure)
      
      false
    end
  end
end
