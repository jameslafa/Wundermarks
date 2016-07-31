class AddUsernameToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :username, :string
    add_index :user_profiles, :username, unique: true
  end
end
