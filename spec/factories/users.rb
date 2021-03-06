FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "admin123"
    password_confirmation "admin123"
    confirmed_at { Time.now.utc }
    role 'regular'

    factory :admin do
      role 'admin'
    end

    factory :user_with_metadatum do
      association :user_metadatum
    end
  end
end
