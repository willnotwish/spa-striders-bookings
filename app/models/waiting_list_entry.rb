class WaitingListEntry < ApplicationRecord
  belongs_to :user
  belongs_to :waiting_list
  belongs_to :booking, optional: true, autosave: true

  validates :user, uniqueness: { scope: :waiting_list_id }
end
