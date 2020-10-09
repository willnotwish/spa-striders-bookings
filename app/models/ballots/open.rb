module Ballots
  class Open
    include ActiveModel::Model

    attr_accessor :ballot, :current_user

    validates :ballot, presence: true, 'ballots/may_open': true

    def save
      return false if invalid?
      
      ballot.open!(user: current_user)
      true
    end
  end
end
