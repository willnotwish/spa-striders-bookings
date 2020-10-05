class Ballot < ApplicationRecord
  belongs_to :event
  
  has_many :ballot_entries, autosave: true
  has_many :users, through: :ballot_entries

  with_options class_name: 'BallotEntry' do
    has_many :successful_entries, -> { successful }
    has_many :unsuccessful_entries, -> { unsuccessful }
  end

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

  # def has_space?
  #   !full?
  # end

  # def full?
  #   return false if capacity.blank?

  #   ballot_entries.count <= capacity
  # end

  aasm do
    state :closed, initial: true
    state :opened
    state :drawn

    event :open, guard: [AuthorizedToOpenGuard, EventNotStartedGuard] do
      transitions from: :closed, to: :opened
    end

    event :close, guard: AuthorizedToCloseGuard do
      transitions from: :opened, to: :closed
    end

    event :draw, guard: [AuthorizedToDrawGuard,
                         EventNotStartedGuard,
                         EventLockedGuard,
                         NoDuplicateEntriesGuard] do
      transitions from:  :closed, 
                  to:    :drawn, 
                  after: DrawService
    end
  end
end
