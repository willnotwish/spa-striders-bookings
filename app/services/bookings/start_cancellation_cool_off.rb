module Bookings
  class StartCancellationCoolOff < ApplicationService
    attr_reader :cooling_off_period

    def initialize(model, cooling_off_period: nil, **)
      super
      @cooling_off_period = cooling_off_period
    end

    def call
      if cooling_off_period.present?
        model.cancellation_cool_off_expires_at = cooling_off_period.from_now
      end
    end
  end
end
