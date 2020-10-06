module Ballots
  class MayOpenValidator < ActiveModel::EachValidator
    def event_name
      :open
    end
  
    def validate_each(record, attribute, value)
      raise 'Missing event in validates options' unless event_name.present?
      return unless value
  
      collector = ->(reason) { record.errors[attribute] << reason }
  
      value.send("may_#{event_name}?", user: record.current_user, guard_failures_collector: collector)
    end
  end  
end