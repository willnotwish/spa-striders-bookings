class BallotPolicy < ApplicationPolicy
  alias_method :ballot, :record

  delegate :event, to: :ballot, allow_nil: true
  delegate :event_admin_users, to: :event, allow_nil: true

  def open?
    return false unless user
    return true if user.admin?
    
    event_admin_users&.include?(user)
  end

  def close?
    user&.admin?
  end

  def draw?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      user.admin? ? scope.all : scope.opened
    end
  end
end
