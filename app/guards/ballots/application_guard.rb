module Ballots
  class ApplicationGuard
    attr_reader :options, :user, :ballot

    def initialize(*args)
      @options = args.extract_options!
      @ballot = args[0].ballot
      @user = args[1]
    end

    private

    def guard_against(failure, &block)
      raise 'No block supplied' unless block_given?
      return true if yield

      collector = options[:guard_failures_collector]
      collector&.call(failure)
      
      false
    end
  end
end
