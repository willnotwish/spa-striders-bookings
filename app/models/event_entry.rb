class EventEntry < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :booking, optional: true, autosave: true

  validates :user, uniqueness: { scope: :event_id }
end
