FactoryBot.define do
  factory :ballot_entry do
    user { nil }
    ballot { nil }
    result { 1 }
  end
end
