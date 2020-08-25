module Admin
  module Event
    class Restriction
      include HasEvent

      validates :event, may_fire: { aasm_event: :restrict }

      def change_state
        event.restrict
      end
    end
  end
end
