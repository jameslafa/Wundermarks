class AddUserPreferenceToExistingUsers < ActiveRecord::Migration
  def up
    say_with_time("Add default UserPreference to every existing user") do
      users = User.all
      ActiveRecord::Base.transaction do
        pbar = ProgressBar.create(:title => "Loop on every users", :starting_at => 0, :total => users.size)
        users.each do |user|
          unless user.user_preference.present?
            user.build_user_preference
            user.save
          end
          pbar.increment
        end
      end
    end
  end

  def down
    UserPreference.destroy_all
  end
end
