FactoryBot.define do
  factory :waiting_list do
    event { nil }
    size { 1 }
    aasm_state { 1 }
  end
end
