class HasSpaceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.has_space?
      record.errors[attribute] << (options[:message] || "has no space")
    end
  end
end