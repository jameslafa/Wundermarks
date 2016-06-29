FactoryGirl.define do
  factory :bookmark do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence(2) }
    url { Faker::Internet.url }
    association :user, factory: :user
  end
end
