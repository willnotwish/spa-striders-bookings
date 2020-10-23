class BookingPolicy < ApplicationPolicy
  include EventTiming
  include EventHasSpace
  include BookingExpiry

  alias_method :booking, :record

  with_options allow_nil: true do
    delegate :event, :cancellation_cool_off_expires_at, to: :booking
    delegate :event_admin_users, to: :event
    delegate :published?, to: :event, prefix: :event
  end

  def create?
    with_admin_defaults do
      return false unless event_admin_or_owner?

      !event_started? && event_published? && event_has_space?
    end
  end

  def with_admin_defaults
    return false if user.blank?
    return true if user.admin?

    yield
  end

  def cancel?
    cancel_or_confirm?
  end

  def confirm?
    cancel_or_confirm?
  end

  def reinstate?
    # Anonymous users can't reinstate
    return false unless user

    # Admins can reinstate regardless of any other considerations
    return true if user.admin?

    # Anyone other than event admins or owners are not allowed
    return false unless event_admin_or_owner?

    # Owners and/or event admins to here
    return false if event_started?

    # If we're still in the cooling off period alles ist in Ordnung
    cancellation_cool_off_expires_at.tap do |expires_at|
      return true if expires_at.present? && Time.current < expires_at
    end

    # It's just like we're making a new, direct booking now
    event_published? && event_has_space?
  end

  # Unauthenticated users see no bookings; admins see them all.
  # Regular users see the bookings they've made.
  # Event admins see bookings for events they administer, in addition.
  class Scope < Scope
    def resolve
      with_defaults do
        # A left outer join is necessary because we need to include all bookings
        # in the query, not just those included as a result of events administered.
        scope.left_outer_joins(event: :event_admins)
             .merge(user.bookings.or(user.event_admins))
             .distinct
      end
    end
  end

  private

  def event_admin_or_owner?
    return true if event_admin_users&.include?(user)

    user == booking&.user
  end

  def cancel_or_confirm?
    return false unless user
    return true if user.admin?
    return false unless event_admin_or_owner?

    !event_started? && !booking_expired?
  end
end
