class WaitingList < ApplicationRecord
  belongs_to :event

  has_many :waiting_list_entries
  has_many :users, through: :waiting_list_entries

  # If the size is nil, the ballot is unlimited
  validates :size, numericality: { only_integer: true, greater_than: 0 },
                   allow_nil: true
end
