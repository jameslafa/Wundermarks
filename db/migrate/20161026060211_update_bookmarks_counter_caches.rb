class UpdateBookmarksCounterCaches < ActiveRecord::Migration
  def up
    users = User.all
    ActiveRecord::Base.transaction do
      pbar = ProgressBar.create(:title => "Update Bookmarks Counters on Users", :starting_at => 0, :total => users.size)
      users.each do |user|
        User.reset_counters(user.id, :bookmarks)
        user.wundermarks_count = Bookmark.where(user_id: user.id, source: 'wundermarks').count
        user.save
        pbar.increment
      end
    end
  end

  def down
    raise IrreversibleMigration
  end
end
