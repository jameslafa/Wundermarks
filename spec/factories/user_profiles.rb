FactoryGirl.define do
  factory :user_profile do
    association :user
    name { Faker::Name.name }
    introduction { Faker::Hipster.paragraph(2) }
  end
end
