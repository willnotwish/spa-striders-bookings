module Ballots
  class Transition < ApplicationRecord
    belongs_to :source, polymorphic: true, optional: true
    belongs_to :ballot
  end
end
