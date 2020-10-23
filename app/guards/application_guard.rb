class ApplicationGuard
  attr_reader :model, :failures_collector

  def initialize(model, guard_failures_collector: nil, failure_reason: nil, **)
    raise 'Model must be specified as first argument' unless model

    @model = model
    @failures_collector = guard_failures_collector
    @custom_failure_reason = failure_reason
  end

  def failure_reason
    @custom_failure_reason || :"#{self.class.name.demodulize.underscore}_failed"
  end

  def call
    return true if pass?

    failures_collector&.call(failure_reason)
    false
  end

  private

  def guard_against(failure, &block)
    raise 'You must supply a block when calling guard_against_failure' unless block_given?
    return true if yield

    failures_collector&.call(failure)
    false
  end
end
