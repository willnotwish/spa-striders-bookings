# frozen_string_literal: true

# SelfServiceBooking
class SelfServiceBooking
  include BookingOperation

  validates :event, 'events/has_space': true,
                    'events/future': true,
                    'events/published': true

  validates :user, has_contact_number: true,
                   has_accepted_terms: true

  def save
    return false if invalid?

    booking.save!
    notify_owner
    true
  end

  private

  def build_booking
    ::Booking.new(user: user, event: event, aasm_state: :confirmed)
  end

  def notify_owner
    Bookings::NotificationsMailer.with(recipient: user, booking: booking)
                                 .confirmed
                                 .deliver_later
  end
end
