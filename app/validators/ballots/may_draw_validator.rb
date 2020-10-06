module Ballots
  class MayDrawValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      return unless value
  
      collector = ->(reason) { record.errors[attribute] << reason }  
      value.send("may_draw?", user: record.current_user, guard_failures_collector: collector)
    end
  end  
end
