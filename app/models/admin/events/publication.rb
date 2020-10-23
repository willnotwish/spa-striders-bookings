module Admin
  module Events
    class Publication
      include ActiveModel::Model

      attr_accessor :event, :current_user

      validates :event, presence: true, aasm_event: { event: :publish }

      def save
        return false if invalid?

        event.publish!(aasm_event_args)
      end

      def aasm_event_args
        { user: current_user }
      end
    end
  end
end
