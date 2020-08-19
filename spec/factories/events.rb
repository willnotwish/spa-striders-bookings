FactoryBot.define do
  factory :event do
    name { "MyString" }
    description { "MyText" }
    starts_at { "2020-08-19 10:32:42" }
    capacity { 1 }
  end
end
