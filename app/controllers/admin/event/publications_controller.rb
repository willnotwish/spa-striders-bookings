module Admin
  module Event
    class PublicationsController < ApplicationController
      before_action :find_event
      before_action :build_publication
      
      def new
        respond_with @publication
      end

      def create
        @publication.save
        
        respond_with @publication, location: [:admin, @event]
      end

      private

      def event_scope
        policy_scope(::Event)
      end

      def find_event
        @event = event_scope.find(params[:event_id])
      end

      def build_publication
        attrs = {
          event: @event,
          published_by: current_user,
          published_at: Time.now, 
        }
        @publication = Publication.new publication_params.merge(attrs)
      end

      def publication_params
        params.fetch(:admin_event_publication, {}).permit()
      end
    end
  end
end
