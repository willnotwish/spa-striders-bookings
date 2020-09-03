FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    members_user_id { Faker::Number.unique.number(digits: 10) }
    accepted_terms_at { 1.day.ago }

    factory :admin do
      admin { true }
    end
  end
end
