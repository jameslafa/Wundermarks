FactoryGirl.define do
  factory :user_profile do
    association :user
    name { Faker::Name.name }
    sequence :username do |n|
      "johnsnow#{n}"
    end
    introduction { Faker::Hipster.paragraph(2) }
  end
end
