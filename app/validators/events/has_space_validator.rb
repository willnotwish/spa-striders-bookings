module Events
  class HasSpaceValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value

      unless EventWrapper.new(value).event_has_space?
        record.errors[attribute] << (options[:message] || "has no space")
      end
    end

    private

    class EventWrapper
      include EventHasSpace
      attr_reader :event

      def initialize(event)
        @event = event
      end
    end
  end
end
