module Bookings
  class Cancellation
    include ActiveModel::Model

    attr_accessor :booking, :current_user, :cooling_off_period
    delegate :event, to: :booking
    
    validates :booking, presence: true
    validate :may_cancel

    def save
      return false if invalid?
      
      booking.cancel! aasm_event_args
      EventPopulationJob.set(wait: cooling_off_period).perform_later(event)
      notify_owner
    end

    private

    def aasm_event_args
      { user: current_user, cooling_off_period: cooling_off_period }
    end

    def may_cancel
      return unless booking

      collector = ->(reason) { @errors[:booking] << reason }
      merged_args = aasm_event_args.merge(guard_failures_collector: collector)
      booking.may_cancel?(merged_args)
    end

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
