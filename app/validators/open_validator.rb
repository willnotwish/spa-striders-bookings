class OpenValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.opened?
      record.errors[attribute] << (options[:message] || "is not open")
    end
  end
end
