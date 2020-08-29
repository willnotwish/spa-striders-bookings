module Admin
  module Event
    module HasEvent
      extend ActiveSupport::Concern
      include ActiveModel::Model

      included do
        attr_accessor :event

        validates :event, presence: true
      end

      def save
        return false if invalid?

        change_state
        event.save
      end
    end
  end
end
