FactoryGirl.define do
  factory :bookmark_tracking do
    association :bookmark
    source :facebook
    count 1

    factory :bookmark_tracking_wundermarks do
      source :wundermarks
    end

    factory :bookmark_tracking_facebook do
      source :facebook
    end

    factory :bookmark_tracking_twitter do
      source :twitter
    end
  end
end
