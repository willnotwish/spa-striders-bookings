class Ballot < ApplicationRecord
  belongs_to :event
  
  has_many :ballot_entries, autosave: true
  has_many :users, through: :ballot_entries

  with_options class_name: 'BallotEntry' do
    has_many :successful_entries, -> { successful }
    has_many :unsuccessful_entries, -> { unsuccessful }
  end

  has_many :transitions, class_name: 'Ballots::Transition'

  validates :opens_at, :closes_at, presence: true

  # If the size is nil, the ballot is unlimited
  validates :size, numericality: { only_integer: true, greater_than: 0 },
                   allow_nil: true

  enum aasm_state: {
    opened:    30, # accepting entries
    closed:    40, # no more entries
    drawn:     50  # drawn at least once
  }

  include AASM
  aasm enum: true do
    state :closed, initial: true
    state :opened
    state :drawn

    event :open, guard: [
      Ballots::AuthorizedToOpenGuard, 
      Ballots::EventNotStartedGuard] do
      transitions from: :closed, to: :opened
    end

    event :close, guard: Ballots::AuthorizedToCloseGuard do
      transitions from: :opened, to: :closed
    end

    event :draw, guard: [
      Ballots::AuthorizedToDrawGuard,
      Ballots::EventNotStartedGuard,
      Ballots::EventLockedGuard,
      Ballots::NoDuplicateEntriesGuard] do
      transitions from:  :closed, 
                  to:    :drawn, 
                  after: Ballots::DrawService
    end

    after_all_transitions StateTransitionBuilderService
  end
end
