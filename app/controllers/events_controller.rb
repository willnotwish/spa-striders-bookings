class EventsController < ApplicationController
  def show
    @event = event_scope.find params[:id]
    respond_with @event
  end

  private

  def event_scope
    policy_scope(Event)
  end
end
