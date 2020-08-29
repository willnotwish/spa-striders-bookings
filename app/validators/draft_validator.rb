class DraftValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.draft?
      record.errors[attribute] << (options[:message] || "is not in a draft state")
    end
  end
end
