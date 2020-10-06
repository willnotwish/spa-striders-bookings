class StatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    state = options[:state]
    unless value.aasm_state == state.to_s
      record.errors[attribute] << (options[:message] || "is not in the #{target} state")
    end
  end
end
