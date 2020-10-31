module BookingExpiry
  extend ActiveSupport::Concern

  def booking_expired?
    return false if booking.expires_at.blank?

    Time.current > booking.expires_at
  end
end
