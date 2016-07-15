FactoryGirl.define do
  factory :email do
    from { Faker::Internet.email }
    to { Faker::Internet.email }
    subject { Faker::Lorem.sentence }
    text { Faker::Lorem.paragraph(2) }

    association :user, factory: :user
  end
end
