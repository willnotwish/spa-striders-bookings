class MayValidator < ActiveModel::EachValidator
  def validate_each(model, attribute, value)
    return unless value

    event = options[:event]
    raise 'Missing event in options for MayValidator' unless event.present?

    collector = ->(reason) { model.errors[attribute] << reason }  

    value.send("may_#{event}?",
      user: model.current_user,
      guard_failures_collector: collector)
  end
end
