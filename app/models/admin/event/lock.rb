module Admin
  module Event
    class Lock
      include HasEvent

      validates :event, may_fire: { aasm_event: :lock }

      def change_state
        event.lock
      end
    end
  end
end
