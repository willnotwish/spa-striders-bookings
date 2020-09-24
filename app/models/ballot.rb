class Ballot < ApplicationRecord
  belongs_to :event
  
  has_many :ballot_entries
  has_many :users, through: :ballot_entries

  validates :opens_at, :drawn_at, presence: true
end
