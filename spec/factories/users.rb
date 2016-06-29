FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "admin123"
    password_confirmation "admin123"
    confirmed_at { Time.now.utc }
  end
end
