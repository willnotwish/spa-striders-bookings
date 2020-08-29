module Admin
  class UserBookingStatsComponent < ApplicationComponent
    attr_reader :user

    delegate :confirmed_bookings, :cancelled_bookings, to: :user

    def initialize(user:)
      @user = user
    end

    def confirmed_bookings_count
      confirmed_bookings.count
    end

    def cancelled_bookings_count
      cancelled_bookings.count
    end
  end
end
