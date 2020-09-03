module Admin
  # Adds user decoration to base (non-namespaced) booking component.
  class BookingComponent < ::BookingComponent
    include UserName

    delegate :user, to: :booking
    delegate :email, :contact_number, to: :user, prefix: :user
  end
end
