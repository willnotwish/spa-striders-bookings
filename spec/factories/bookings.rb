FactoryBot.define do
  factory :booking do
    event { nil }
    user { nil }
    aasm_state { 1 }
    notes { "MyText" }
  end
end
