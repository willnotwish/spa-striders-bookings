FactoryBot.define do
  factory :events_config_data, class: 'Events::ConfigData' do
    booking_cancellation_cooling_off_period_in_minutes { 15 }
    entry_selection_strategy { :first_come_first_served }
    booking_confirmation_period_in_minutes { 320 }
  end
end
