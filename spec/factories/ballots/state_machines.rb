FactoryBot.define do
  factory :ballots_state_machine, class: 'Ballots::StateMachine' do
    ballot { nil }
  end
end
