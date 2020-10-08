module Bookings
  class Cancellation
    include ActiveModel::Model

    attr_accessor :booking, :current_user
    validates :booking, presence: true, may: { event: :cancel }

    def save
      return false if invalid?
      
      booking.cancel!(user: current_user)
      notify_owner
    end

    private

    def notify_owner
      params = {
        recipient: booking.user, 
        booking: booking,
        source: current_user
      }

      NotificationsMailer.with(params).cancelled.deliver_later
    end

    # def notify_event_admins
    #   params = {
    #     recipient: booking.event.event_admins, 
    #     booking: booking,
    #     source: current_user
    #   }

    #   NotificationsMailer.with(params).cancelled.deliver_later
    # end
  end
end
