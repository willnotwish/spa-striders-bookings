FactoryBot.define do
  factory :events_config_data, class: 'Events::ConfigData' do
    booking_cancellation_cooling_off_period_in_minutes { 1 }
    entry_selection_strategy { 1 }
    booking_confirmation_period_in_minutes { 1 }
  end
end
