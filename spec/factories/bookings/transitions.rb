FactoryBot.define do
  factory :bookings_transition, class: 'Bookings::Transition' do
    booking { nil }
    from_state { "MyString" }
    to_state { "MyString" }
    source { nil }
  end
end
