class FutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.future?
      record.errors[attribute] << (options[:message] || "has already happened")
    end
  end
end