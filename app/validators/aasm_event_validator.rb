class AasmEventValidator < ActiveModel::EachValidator
  def event_name
    options[:event]
  end

  def args_method
    options[:aasm_event_args] || :aasm_event_args
  end

  def validate_each(record, attribute, value)
    return unless value

    raise 'Missing event in options' unless event_name.present?
    raise "Value must respond to #{args_method}" unless record.respond_to?(args_method)

    collector = ->(reason) { record.errors[attribute] << reason }
    args = record.send(args_method)
    args = args.merge(guard_failures_collector: collector)

    unless value.send("may_#{event_name}?", args)
      record.errors[attribute].unshift "will not allow the #{event_name} event in its current state (#{value.aasm.current_state})"
    end
  end
end
