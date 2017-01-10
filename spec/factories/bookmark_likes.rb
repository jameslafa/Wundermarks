FactoryGirl.define do
  factory :bookmark_like do
    association :bookmark
    association :user    
  end
end
