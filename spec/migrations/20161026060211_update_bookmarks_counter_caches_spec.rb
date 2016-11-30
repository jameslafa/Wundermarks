load 'db/migrate/20161026060211_update_bookmarks_counter_caches.rb'

describe UpdateBookmarksCounterCaches, migration: true do
  before do
    @my_migration_version = '20161026060211'
    @previous_migration_version = '20161026055702'
  end

  describe "up" do
    before do
      ActiveRecord::Migrator.migrate @previous_migration_version
      puts "Testing up migration for #{@my_migration_version} - resetting to #{ActiveRecord::Migrator.current_version}"
    end

    it "update counters" do
      users = create_list(:user, 2)
      user_1 = users[0]
      user_2 = users[1]

      create_list(:bookmark, 2, user_id: user_1.id, source: 'wundermarks')
      create(:bookmark, user_id: user_1.id, source: 'delicious')
      create_list(:bookmark, 3, user_id: user_2.id, source: 'wundermarks')

      user_1.update_attributes({bookmarks_count: 0, wundermarks_count: 0})
      user_2.update_attributes({bookmarks_count: 0, wundermarks_count: 0})

      UpdateBookmarksCounterCaches.new.up
      user_1.reload
      user_2.reload

      expect(user_1.bookmarks_count).to eq 3
      expect(user_1.wundermarks_count).to eq 2

      expect(user_2.bookmarks_count).to eq 3
      expect(user_2.wundermarks_count).to eq 3
    end
  end
end
