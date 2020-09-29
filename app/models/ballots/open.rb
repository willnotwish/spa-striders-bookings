module Ballots
  class Open
    include ActiveModel::Model

    attr_accessor :ballot, :current_user
    validates :ballot, presence: true

    validate :may_open

    def save
      return false if invalid?
      
      state_machine.open(current_user)
    end

    private

    def state_machine
      @state_machine ||= StateMachine.new(ballot)      
    end

    def may_open
      return unless ballot

      state_machine.may_open?(current_user)
    end

    class << self
      def create(attrs)
        new(attrs).tap { |instance| instance.save }
      end
    end
  end
end
