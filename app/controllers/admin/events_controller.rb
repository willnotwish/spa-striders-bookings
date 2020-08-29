module Admin
  class EventsController < ApplicationController
    before_action :find_event, except: %i[index new create]

    respond_to :html
    
    def index
      @events = base_scope.order(:starts_at)
      respond_with :admin, @events
    end

    def new
      @event = base_scope.new event_params.merge(aasm_state: :draft)
      respond_with :admin, @event
    end

    def create
      @event = base_scope.create event_params.merge(aasm_state: :draft)
      respond_with :admin, @event
    end

    def edit
      respond_with :admin, @event
    end

    def update
      @event.update event_params
      respond_with :admin, @event
    end

    def show
      respond_with :admin, @event
    end

    private

    def find_event
      @event = base_scope.find params[:id]
    end

    def event_params
      params.fetch(:event, {}).permit(:name, :description, :capacity, :starts_at)
    end

    def base_scope
      policy_scope(::Event)
    end
  end
end
