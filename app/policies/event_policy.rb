class EventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      user&.admin? ? scope.all : scope.published
    end
  end
end
