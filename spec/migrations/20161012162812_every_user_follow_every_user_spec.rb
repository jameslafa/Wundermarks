load 'db/migrate/20161012162812_every_user_follow_every_user.rb'

describe EveryUserFollowEveryUser, migration: true do
  before do
    @my_migration_version = '20161010064700'
    @previous_migration_version = '20161012162812'
  end

  describe "up" do
    before do
      ActiveRecord::Migrator.migrate @previous_migration_version
      puts "Testing up migration for #{@my_migration_version} - resetting to #{ActiveRecord::Migrator.current_version}"
    end

    it "makes every user to follow every other user" do
      users = create_list(:user, 3)

      expect{
        EveryUserFollowEveryUser.new.up
      }.to change(Follow, :count).by(6)

      expect(users[0].all_following).to match_array [users[1], users[2]]
      expect(users[1].all_following).to match_array [users[0], users[2]]
      expect(users[2].all_following).to match_array [users[0], users[1]]
    end
  end

end
