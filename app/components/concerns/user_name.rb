module UserName
  extend ActiveSupport::Concern

  included do
    delegate :first_name, :last_name, to: :user
  end

  def user_name
    names = []
    names << first_name if first_name.present?
    names << last_name if last_name.present?
    names.join(' ')
  end
end
