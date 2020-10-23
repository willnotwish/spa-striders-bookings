# This is a poor implementation. It assumes that the may_xxx? method
# is called with only the current_user as a parameter.
# This may not always be the case. The validator should not
# make any assumptions about parameters passed to the aasm event.

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
