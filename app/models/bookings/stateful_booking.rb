module Bookings
  class StatefulBooking
    include AASM

    aasm do 
      state :provisional, initial: true
      state :confirmed, after_enter: %i[reset_expires_at notify_confirmation]
      state :cancelled, after_enter: :notify_cancellation

      event :confirm do
        transitions from:  :provisional,
                    to:    :confirmed,
                    guard: Guards::Confirmable
      end

      event :cancel do
        transitions from:  %i[provisional confirmed], 
                    to:    :cancelled,
                    guard: Guards::Cancellable
      end

      event :reinstate do
        transitions from:  :cancelled,
                    to:    :confirmed,
                    guard: :reinstatable?
      end

      after_all_transitions :persist_changes!, :record_transition
    end

    attr_reader :booking

    def initialize(booking)
      @booking = booking
      aasm.current_state = booking.aasm_state.to_sym
    end
    
    private

    delegate :event, :logger, to: :booking

    # Before/after callbacks
    def persist_changes!
      booking.update! aasm_state: aasm.to_state
    end

    def record_transition(source = nil, options = {})
      booking.transitions.create(source: source, 
                                 from_state: aasm.from_state,
                                 to_state: aasm.to_state)
    end

    def notify_cancellation(source = nil, options = {})
      unless options[:skip_notification]
        NotificationsMailer.with(source: source, booking: booking)
          .cancelled
          .deliver_later
      end
    end

    def notify_confirmation(source = nil, options = {})
      unless options[:skip_notification]
        NotificationsMailer.with(source: source, booking: booking, options: options)
          .confirmed
          .deliver_later
      end
    end

    def reset_expires_at
      booking.expires_at = nil
    end

    # Guards
    # 

    # def cancellable?(source = nil)
    #   return true if admin_source?(source)

    #   booking.future?
    # end

    # # A self service user cannot confirm a booking if it has expired
    # def confirmable?(source = nil)
    #   return true if admin_source?(source) || booking.expires_at.blank?
      
    #   Time.now < booking.expires_at
    # end

    # A booking is reinstatable if the number of provisional + confirmed
    # bookings is less than the event's capacity. Admins can override this.
    def reinstatable?(source = nil)
      return true if admin_source?(source)

      event.bookings.provisional_or_confirmed.count < event.capacity
    end

    # Private helpers
    def admin_source?(source)
      return false unless source
      
      source.respond_to?(:admin?) && source.admin?
    end

    def self_service?(source)
      return false if admin_source?(source)

      source == booking.user
    end
  end
end
