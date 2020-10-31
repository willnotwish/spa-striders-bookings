module Events
  class ConfigData < ApplicationRecord
    # t.integer "booking_cancellation_cooling_off_period_in_minutes"
    # t.integer "entry_selection_strategy"
    # t.integer "booking_confirmation_period_in_minutes"

    enum entry_selection_strategy: {
      first_come_first_served: 10,
      ballot: 20
    }
  end
end
