module Admin
  class BallotsController < ApplicationController
    
    def index
      find_event if params[:event_id].present?

      @ballots = ballot_scope.all
      @ballots = @ballots.where(event: @event) if @event
      
      respond_with :admin, @ballots
    end

    def show
      find_ballot
      @event = @ballot.event

      respond_with :admin, @ballot
    end

    def new
      find_event

      @ballot = @event.ballots.build(ballot_params)
      respond_with :admin, @ballot
    end

    def create
      find_event

      @ballot = @event.ballots.create(ballot_params.merge(aasm_state: :closed))
      respond_with :admin, @ballot
    end

    private

    def event_scope
      policy_scope(::Event)
    end

    def ballot_scope
      policy_scope(::Ballot)
    end

    def find_ballot
      @ballot = ballot_scope.find params[:id]
    end

    def find_event
      @event = event_scope.find params[:event_id]
    end

    def ballot_params
      params.fetch(:ballot, { opens_at: @event.starts_at - 3.days, closes_at: @event.starts_at - 1.day}).permit(:size, :opens_at, :closes_at, :rules)
    end
  end
end
