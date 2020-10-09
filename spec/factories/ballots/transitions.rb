FactoryBot.define do
  factory :ballots_transition, class: 'Ballots::Transition' do
    source { nil }
    ballot { nil }
    from_state { "MyString" }
    to_state { "MyString" }
  end
end
