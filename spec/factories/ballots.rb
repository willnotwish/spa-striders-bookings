FactoryBot.define do
  factory :ballot do
    event { nil }
    size { 10 }
    opens_at { 1.day.from_now }
    closes_at { 8.days.from_now }
  end
end
