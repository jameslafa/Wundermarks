class RemoveWundermarksCountFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :bookmarks_count
    remove_column :users, :wundermarks_count
  end
end
