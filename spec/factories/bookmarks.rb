FactoryGirl.define do
  factory :bookmark do
    title { Faker::Lorem.sentence.truncate(Bookmark::MAX_TITLE_LENGTH) }
    description { Faker::Lorem.sentence(2).truncate(Bookmark::MAX_DESCRIPTION_LENGTH) }
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
  end
end
