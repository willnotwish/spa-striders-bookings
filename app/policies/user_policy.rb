# Defines who has access to users
class UserPolicy < ApplicationPolicy
  alias_method :user, :record

  # Unauthenticated users see no-one; admins see everyone.
  # Regular users see themselves!
  # Event admins see those with bookings for event they administer, in addition.
  class Scope < Scope
    def resolve
      with_defaults do
        scope.left_outer_joins(bookings: { event: :event_admins })
             .merge(scope.where(id: user.id).or(user.event_admins))
             .distinct
      end
    end
  end
end
