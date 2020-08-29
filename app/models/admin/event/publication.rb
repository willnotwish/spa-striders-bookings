module Admin
  module Event
    class Publication
      include HasEvent

      attr_accessor :published_by,
                    :published_at

      validates :event, may_fire: { aasm_event: :publish }

      # Events are published by admins
      validates :published_by, presence: true, admin: true
      validates :published_at, presence: true

      def change_state
        event.publish
        event.update(published_by: published_by,
                     published_at: published_at)
      end
    end
  end
end
