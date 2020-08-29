class MayFireValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.send("may_#{options[:aasm_event]}?")
      record.errors[attribute] << (options[:message] || "may not fire aasm event: #{options[:aasm_event]}")
    end
  end
end
