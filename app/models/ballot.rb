class Ballot < ApplicationRecord
  belongs_to :event
  
  has_many :ballot_entries
  has_many :successful_entries, -> { successful }, class_name: 'BallotEntry'
  has_many :unsuccessful_entries, -> { unsuccessful }, class_name: 'BallotEntry'
  has_many :users, through: :ballot_entries

  validates :opens_at, :closes_at, presence: true

  # If the size is nil, the ballot is unlimited
  validates :size, numericality: { only_integer: true, greater_than: 0 },
                   allow_nil: true

  enum aasm_state: {
    # draft:     10, # no visibility (initial state)
    # published: 20, # visible to everyone
    opened:    30, # accepting entries
    closed:    40, # no more entries
    drawn:     50  # all done (final state)
  }
end
