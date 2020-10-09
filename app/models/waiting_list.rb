class WaitingList < ApplicationRecord
  belongs_to :event

  has_many :entries, class_name: 'WaitingListEntry'
  has_many :users, through: :entries

  # If the size is nil, the max length of the list is unlimited
  validates :size, numericality: { only_integer: true, greater_than: 0 },
                   allow_nil: true
end
