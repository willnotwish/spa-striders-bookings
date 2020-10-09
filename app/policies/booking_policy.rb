class BookingPolicy < ApplicationPolicy
  include EventTiming
  include BookingExpiry

  alias_method :booking, :record

  delegate :event, to: :booking, allow_nil: true
  delegate :event_admin_users, to: :event, allow_nil: true

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

    !event_started? && event_has_space?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.admin?
      
      # Include bookings for any events managed by the user
      administered_bookings = Booking.joins(:event)
        .merge(user.administered_events)
      scope = scope.merge(administered_bookings)

      # Include the bookings involving the user directly (ie, their bookings)
      scope = scope.merge(user.bookings)
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
