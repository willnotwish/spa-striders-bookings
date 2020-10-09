FactoryBot.define do
  factory :events_transition, class: 'Events::Transition' do
    source { nil }
    event { nil }
    from_state { "MyString" }
    to_state { "MyString" }
  end
end
