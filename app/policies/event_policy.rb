# Pundit policy
class EventPolicy < ApplicationPolicy
  alias_method :event, :record

  def populate?
    admin?
  end

  def publish?
    admin?
  end

  def lock?
    admin?
  end

  def restrict?
    admin?
  end

  # Unauthenticated users see no events; admins see them all.
  # Users see events they've booked, together with any non-draft events.
  # Event admins see the events they administer in addition.
  class Scope < Scope
    def resolve
      with_defaults do
        conditions = scope.not_draft
                          .or(user.bookings)
                          .or(user.event_admins)
        # A left outer join is necessary because we need to include all events
        # in the query, not just those included as a result of bookings made or
        # events administered.
        scope.left_outer_joins(:event_admins, :bookings).merge(conditions)
      end
    end
  end

  private

  def admin?
    return false if user.blank?
    return true if user.admin?

    event.event_admin_users.include?(user)
  end
end
