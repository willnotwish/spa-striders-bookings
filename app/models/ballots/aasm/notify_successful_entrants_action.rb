module Ballots
  module Aasm
    class NotifySuccessfulEntrantsAction
      attr_reader :options, :user, :stateful_ballot

      delegate :ballot, :pending_notifications, to: :stateful_ballot
      delegate :logger, to: :ballot

      # delegate :event, :ballot_entries, to: :ballot

      def initialize(*args)
        @options = args.extract_options!
        @stateful_ballot = args[0]
        @user = args[1]
      end

      def disabled?
        options.fetch(:skip_successful_entrant_notification, false)
      end

      def enabled?
        !disabled?
      end

      # Notifications can be sent to all those ballot entrants who have been
      # assigned a booking via the ballot, or only to those that are new (that
      # is, have not yet been saved).
      def only_new_bookings?
        logger.warn "NotifySuccessfulEntrantsAction#only_new_bookings? always returns true. TODO: make this a configurable option"
        true        
      end

      def call
        return if disabled?
        
        notifiable_entries.each do |entry|
          booking = entry.booking
          pending_notifications << 
            NotificationsMailer.with(recipient: booking.user, booking: booking)
              .success
        end
      end

      private

      def notifiable_entries
        return [] unless ballot

        # At this point the ballot and its associated bookings 
        # have not been saved. We use this to work out which entries are
        # new, and hence who to notify. Seems a bit flakey. We'll see...
        if only_new_bookings?
          ballot.ballot_entries.select { |entry| entry.booking&.new_record? }
        else
          ballot.ballot_entries.select(&:booking)
        end
      end
    end
  end
end
