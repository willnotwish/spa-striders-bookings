module Admin
  module Event
    class Restriction
      include ActiveModel::Model

      attr_accessor :event, :current_user

      validates :event, presence: true, aasm_event: { event: :restrict }

      def save
        return false if invalid?

        event.lock!(aasm_event_args)
      end

      def aasm_event_args
        { user: current_user }
      end
    end
  end
end
