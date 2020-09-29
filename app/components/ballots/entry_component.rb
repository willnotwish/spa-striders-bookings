module Ballots
  class EntryComponent < ApplicationComponent
    attr_reader :entry

    delegate :user, to: :entry

    def initialize(entry:)
      @entry = entry
    end
  end
end
