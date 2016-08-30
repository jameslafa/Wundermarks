me = User.create(email: 'james@wundermarks.com', password: 'admin123', password_confirmation: 'admin123', role: 'admin')
user_1 = User.create(email: 'user_1@wundermarks.com', password: 'admin123', password_confirmation: 'admin123')
user_2 = User.create(email: 'user_2@wundermarks.com', password: 'admin123', password_confirmation: 'admin123')

profile_me = UserProfile.create(name: 'James Lafa', introduction: 'This is the admin', username: 'james', user: me)
profile_user_1 = UserProfile.create(name: 'User 1', introduction: 'This is the user 1', username: 'user1', user: user_1)
profile_user_2 = UserProfile.create(name: 'User 2', introduction: 'This is the user 2', username: 'user2', user: user_2)

users = User.all
privacy = ['everyone', 'only_me', 'everyone'] # Get twice more everyone

# Create 50 bookmarks for random user and privacy.
FactoryGirl.reload
(1..50).each do |i|
  random_user = users.sample
  FactoryGirl.create(:bookmark_with_tags, user: users.sample, privacy: privacy.sample)
end
