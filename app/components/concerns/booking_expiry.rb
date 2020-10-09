module BookingExpiry
  extend ActiveSupport::Concern

  def booking_expired?
    return false unless booking.expires_at.present?
      
    Time.now > booking.expires_at
  end
end
