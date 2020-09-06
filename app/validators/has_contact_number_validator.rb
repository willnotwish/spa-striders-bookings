class HasContactNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.contact_number&.valid?
      record.errors[attribute] << (options[:message] || "must have a valid contact number")
    end
  end
end