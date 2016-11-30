load 'db/migrate/20161019061125_add_user_preference_to_existing_users.rb'

describe AddUserPreferenceToExistingUsers, migration: true do
  before do
    @my_migration_version = '20161019061125'
    @previous_migration_version = '20161019053231'
  end

  describe "up" do
    before do
      ActiveRecord::Migrator.migrate @previous_migration_version
      puts "Testing up migration for #{@my_migration_version} - resetting to #{ActiveRecord::Migrator.current_version}"
    end

    it "adds preferences to every users" do
      users = create_list(:user, 3)
      UserPreference.destroy_all

      expect{
        AddUserPreferenceToExistingUsers.new.up
      }.to change(UserPreference, :count).by(3)

      expect(User.pluck(:id)).to match_array UserPreference.pluck(:user_id)
    end
  end

  describe "down" do
    before do
      ActiveRecord::Migrator.migrate @my_migration_version
      puts "Testing down migration for #{@my_migration_version} - resetting to #{ActiveRecord::Migrator.current_version}"
    end

    it "destroys every UserPreference" do
      users = create_list(:user, 3)

      expect{
        AddUserPreferenceToExistingUsers.new.down
      }.to change(UserPreference, :count).by(-3)
    end
  end
end
