module Admin
  module Ballots
    class DrawsController < ApplicationController
      before_action :find_ballot
      before_action :build_resource

      def new
        respond_with @open
      end

      def create
        @draw.save

        respond_with @draw, location: [:admin, @ballot]
      end

      private

      def ballot_scope
        policy_scope(Ballot)
      end

      def find_ballot
        @ballot = ballot_scope.find(params[:ballot_id])
      end

      def build_resource
        attrs = permitted_params.merge(ballot: @ballot, current_user: current_user)
        @draw = ::Ballots::Draw.new attrs
      end

      def permitted_params
        params.fetch(:ballots_draw, { notify_winners: true }).permit(:notify_winners)
      end
    end
  end
end

