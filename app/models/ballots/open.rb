module Ballots
  class Open
    include ActiveModel::Model

    attr_reader :ballot
    attr_accessor :current_user

    validates :ballot, presence: true, may_fire_event: { event: :open }

    def ballot=(ballot)
      @ballot = ballot ? StateMachine.new(ballot) : nil
    end

    def save
      return false if invalid?
      
      ballot.open(current_user)
    end
  end
end
