module Admin
  class DashboardController < ApplicationController
    
    def show
      @events = base_scope.upcoming
                          .published
                          .order(starts_at: :asc)
                          .includes(confirmed_bookings: :user)
      respond_with :dashboard
    end

    private

    def base_scope
      policy_scope(::Event)
    end
  end
end
