module Admin
  class AttendanceUpdatesController < ApplicationController
    before_action :build_update

    def new
      respond_with @update
    end

    def create
      @update.save
      
      respond_with @update, location: [:admin, @event]
    end

    private

    def build_update
      @event = event_scope.find params[:event_id]

      @update = AttendanceUpdate.new update_params(@event)
      @update.user = current_user
      @update.event = @event
    end

    def update_params(event)
      defaults = { 
        honoured_booking_ids: event.confirmed_bookings.honoured.pluck(:id)
      }
      params.fetch(:admin_attendance_update, defaults)
            .permit(honoured_booking_ids: [])
    end

    def event_scope
      policy_scope(::Event)
    end
  end
end
