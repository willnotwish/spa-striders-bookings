module Admin
  class AttendanceUpdate
    include ActiveModel::Model
    
    attr_accessor :user, :event, :honoured_booking_ids
    attr_reader :honoured_booking_ids

    validates :user, :event, presence: true

    delegate :confirmed_bookings, to: :event

    def honoured_bookings
      return Booking.none if honoured_booking_ids.blank?

      # Rails (or is it simple_form?) gives us blank IDs in the array 
      # when using check boxes. Ignore these.
      confirmed_bookings.where(id: honoured_booking_ids.select(&:present?))
    end

    # This is a complete update. We update all confirmed bookings, nulling
    # out those that have *not* been honoured
    def save
      return false if invalid?

      confirmed_bookings.all? do |confirmed_booking|
        timestamp = honoured_bookings.include?(confirmed_booking) ? Time.now : nil
        confirmed_booking.update(honoured_at: timestamp, honoured_by: user)
      end
    end

    def booking_label(booking)
      Admin::UserComponent.new(user: booking.user).user_name
    end
  end
end
