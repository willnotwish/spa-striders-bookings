require 'ballots/has_space'

module Ballots
  class HasSpaceValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value

      unless Wrapper.has_space?(value)
        record.errors[attribute] << (options[:message] || "has no space")
      end
    end

    private

    class Wrapper
      include HasSpace
      attr_reader :ballot

      def initialize(ballot)
        @ballot = ballot
      end

      class << self
        def has_space?(ballot)
          new(ballot).ballot_has_space?
        end
      end
    end
  end
end