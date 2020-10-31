FactoryBot.define do
  factory :booking do
    event { nil }
    user { nil }
    aasm_state { :confirmed }
  end
end
