module Events
  class PublishedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value

      unless value.published?
        record.errors[attribute] << (options[:message] || "is not published")
      end
    end
  end
end
