FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    members_user_id { Faker::Number.unique.number(digits: 10) }
  end
end
