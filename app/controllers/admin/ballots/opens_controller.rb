module Admin
  module Ballots
    class OpensController < ApplicationController
      before_action :find_ballot
      before_action :build_resource

      def new
        respond_with @open
      end

      def create
        @open.save

        respond_with @open, location: [:admin, @ballot]
      end

      private

      def ballot_scope
        policy_scope(Ballot)
      end

      def find_ballot
        @ballot = ballot_scope.find(params[:ballot_id])
      end

      def build_resource
        attrs = open_params.merge(ballot: @ballot, current_user: current_user)
        @open = ::Ballots::Open.new attrs
      end

      def open_params
        params.fetch(:ballot_open, {}).permit()
      end
    end
  end
end

