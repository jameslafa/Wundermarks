FactoryGirl.define do
  factory :bookmark do
    title { Faker::Lorem.sentence.truncate(140) }
    description { Faker::Lorem.sentence(2).truncate(255) }
    url { Faker::Internet.url }
    privacy 'everyone'
    association :user, factory: :user

    factory :bookmark_with_tags do
      tag_list { Faker::Hipster.words.uniq.map!(&:parameterize).join(", ") }
    end

    factory :bookmark_visible_to_everyone do
      privacy 'everyone'
    end

    factory :bookmark_visible_to_only_me do
      privacy 'only_me'
    end

    factory :bookmark_visible_to_friends do
      privacy 'friends'
    end
  end
end
