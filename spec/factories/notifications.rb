FactoryGirl.define do
  factory :notification do
    association :recipient, factory: :user
    association :sender, factory: :user
    activity "bookmark_like"
    association :emitter, factory: :bookmark
    read false

    factory :read_notification do
      read true
      read_at { 2.minutes.ago }
    end

    factory :unread_notification do
      read false
      read_at nil
    end
  end
end
