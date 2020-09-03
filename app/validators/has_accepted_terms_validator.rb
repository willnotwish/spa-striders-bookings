class HasAcceptedTermsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.has_accepted_terms?
      record.errors[attribute] << (options[:message] || "must accept the terms and conditions")
    end
  end
end