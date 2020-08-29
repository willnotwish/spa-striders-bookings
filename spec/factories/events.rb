FactoryBot.define do
  factory :event do
    name { "Hill session" }
    starts_at { 2.weeks.from_now }
    capacity { 10 }
    aasm_state { :published }
  end
end
