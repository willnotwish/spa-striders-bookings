module Admin
  class Booking
    include BookingOperation
    
    attr_accessor :current_user
    validates :current_user, presence: true, admin: true

    def save
      return false if invalid?

      booking.save
    end

    private

    def build_booking
      super.tap { |booking| booking.made_by = current_user }
    end
  end
end
