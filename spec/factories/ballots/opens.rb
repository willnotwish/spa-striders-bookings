FactoryBot.define do
  factory :ballots_open, class: 'Ballots::Open' do
    ballot { nil }
    user { nil }
  end
end
