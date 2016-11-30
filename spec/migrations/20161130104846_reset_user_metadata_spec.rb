load 'db/migrate/20161130104846_reset_user_metadata.rb'

describe ResetUserMetadata, migration: true do
  before do
    @my_migration_version = '20161130104846'
    @previous_migration_version = '20161121071734'
  end

  describe "up" do
    before do
      ActiveRecord::Migrator.migrate @previous_migration_version
      puts "Testing up migration for #{@my_migration_version} - resetting to #{ActiveRecord::Migrator.current_version}"
    end

    it "resets users" do
      first_user = create(:user)
      second_user = create(:user)

      create_list(:bookmark, 2, user: first_user)
      create_list(:bookmark, 2, user: second_user)

      UserMetadatum.find_by(user_id: first_user.id).destroy

      ResetUserMetadata.new.up

      expect(first_user.reload.metadata.bookmarks_count).to eq 2
      expect(second_user.reload.metadata.bookmarks_count).to eq 2
    end
  end
end
