class AdminValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.admin?
      record.errors[attribute] << (options[:message] || "must be an admin")
    end
  end
end