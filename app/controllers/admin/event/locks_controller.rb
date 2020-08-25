module Admin
  module Event
    class LocksController < ApplicationController
      before_action :find_event
      before_action :build_lock
      
      def new
        respond_with @lock
      end

      def create
        @lock.save
        
        respond_with @lock, location: [:admin, @event]
      end

      private

      def event_scope
        policy_scope(::Event)
      end

      def find_event
        @event = event_scope.find(params[:event_id])
      end

      def build_lock
        @lock = Lock.new lock_params.merge(event: @event)
      end

      def lock_params
        params.fetch(:admin_event_lock, {}).permit()
      end
    end
  end
end
