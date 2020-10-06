FactoryBot.define do
  factory :waiting_list_entry do
    user { nil }
    waiting_list { nil }
    notes { "MyText" }
  end
end
