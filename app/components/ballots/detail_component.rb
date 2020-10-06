module Ballots
  class DetailComponent < ApplicationComponent

    def initialize(ballot:, except: [])
      super(ballot: ballot, except: except)
    end
  end
end
