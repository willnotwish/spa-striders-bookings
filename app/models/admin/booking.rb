module Admin
  class Booking
    include BookingOperation
    
    attr_accessor :current_user
    validates :current_user, presence: true, admin: true

    private

    def build_booking
      # An admin booking differs froma self-service booking
      # in the sense that it was made by an admin
      super.tap { |booking| booking.made_by = current_user }
    end
  end
end
