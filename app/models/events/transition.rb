module Events
  class Transition < ApplicationRecord
    belongs_to :source, polymorphic: true
    belongs_to :event
  end
end
