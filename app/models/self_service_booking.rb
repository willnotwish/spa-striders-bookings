class SelfServiceBooking
  include BookingOperation

  validates :event, has_space: true, future: true, published: true
end
