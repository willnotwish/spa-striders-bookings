class BallotPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      user.admin? ? scope.all : scope.opened
    end
  end
end
