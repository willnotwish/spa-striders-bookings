class MayFireEventValidator < ActiveModel::EachValidator
  def event_name
    options[:event]
  end

  def validate_each(record, attribute, value)
    raise 'Missing event in validates options' unless event_name.present?
    return unless value

    attribute_name = options[:attribute] || attribute
    collector = ->(reason) { record.errors[attribute_name] << reason }

    opts = { guard_failures_collector: collector }
    value.send("may_#{event_name}?", record.current_user, opts)
  end
end
