module Admin
  module Event
    class RestrictionsController < ApplicationController
      before_action :find_event
      before_action :build_restriction
      
      def new
        respond_with @restriction
      end

      def create
        @restriction.save
        
        respond_with @restriction, location: [:admin, @event]
      end

      private

      def event_scope
        policy_scope(::Event)
      end

      def find_event
        @event = event_scope.find(params[:event_id])
      end

      def build_restriction
        @restriction = Restriction.new restriction_params.merge(event: @event)
      end

      def restriction_params
        params.fetch(:admin_event_restriction, {}).permit()
      end
    end
  end
end
