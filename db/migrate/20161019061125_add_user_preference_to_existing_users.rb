require 'progressbar'

class AddUserPreferenceToExistingUsers < ActiveRecord::Migration
  def up
    say_with_time("Add default UserPreference to every existing user") do
      users = User.all
      ActiveRecord::Base.transaction do
        pbar = ProgressBar.new("Loop on every users", users.size)
        users.each do |user|
          unless user.user_preference.present?
            user.build_user_preference
            user.save
          end
          pbar.inc
        end
        pbar.finish
      end
    end
  end

  def down
    UserPreference.destroy_all
  end
end
