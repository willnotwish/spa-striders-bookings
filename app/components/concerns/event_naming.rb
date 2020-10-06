module EventNaming
  extend ActiveSupport::Concern

  included do
    delegate :name, :description, to: :event, prefix: :event
  end
end
