module Bookings
  class ProvisionalValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value
  
      unless value.provisional?
        record.errors[attribute] << (options[:message] || "is not provisional")
      end
    end
  end
end
