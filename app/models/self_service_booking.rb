class SelfServiceBooking
  include BookingOperation

  validates :event, has_space: true, future: true, published: true
  validates :user, has_contact_number: true, has_accepted_terms: true
end
