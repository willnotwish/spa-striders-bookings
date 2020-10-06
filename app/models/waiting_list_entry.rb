class WaitingListEntry < ApplicationRecord
  belongs_to :user
  belongs_to :waiting_list

  delegate :event, to: :waiting_list
end
