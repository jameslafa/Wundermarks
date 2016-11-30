FactoryGirl.define do
  factory :user_metadatum do
    followers_count 0
    followings_count 0
    bookmarks_count 0
    public_bookmarks_count 0
    association :user
  end
end
