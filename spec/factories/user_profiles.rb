FactoryGirl.define do
  factory :user_profile do
    association :user
    name { Faker::Name.name }
    sequence :username do |n|
      "johnsnow#{n}"
    end
    introduction { Faker::Hipster.paragraph(2) }
    country "DE"
    city "Berlin"
    website "https://wundermarks.com"
    birthday { Date.new(1982, 11, 23) }
    twitter_username "wundermarks"
    github_username "wundermarks"
  end
end
