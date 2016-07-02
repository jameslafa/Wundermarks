FactoryGirl.define do
  factory :bookmark do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence(2) }
    url { Faker::Internet.url }
    association :user, factory: :user

    factory :bookmark_with_tags do
      tag_list { Faker::Hipster.words.join(", ") }
    end
  end
end
