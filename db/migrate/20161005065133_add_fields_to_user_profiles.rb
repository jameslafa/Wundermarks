class AddFieldsToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :country, :string
    add_column :user_profiles, :city, :string
    add_column :user_profiles, :website, :string
    add_column :user_profiles, :birthday, :date
    add_column :user_profiles, :twitter_username, :string
    add_column :user_profiles, :github_username, :string
  end
end
