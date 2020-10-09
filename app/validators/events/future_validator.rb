module Events
  class FutureValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value

      unless EventWrapper.new(value).event_not_started?
        record.errors[attribute] << (options[:message] || "has already happened")
      end
    end

    private

    class EventWrapper
      include EventTiming
      attr_reader :event

      def initialize(event)
        @event = event
      end
    end
  end
end
