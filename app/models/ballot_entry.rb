class BallotEntry < ApplicationRecord
  belongs_to :user
  belongs_to :ballot

  enum result: {
    successful: 1,
    unsuccessful: 2
  }

  delegate :event, to: :ballot
end
