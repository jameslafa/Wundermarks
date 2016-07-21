namespace :data_migration do
  desc "Set tag_search on every bookmark having a tag_search nil"
  task add_bookmark_tag_search: :environment do
    puts "Start data migration to set tag_search on bookmarks."
    bookmarks = Bookmark.where(tag_search: nil)
    bookmark_count = bookmarks.count

    puts "Found #{bookmark_count} bookmarks."

    updated_bookmark = 0
    ActiveRecord::Base.transaction do
      bookmarks.each do |bookmark|
        bookmark.save
        updated_bookmark += 1
      end
    end

    puts "End of data migration. #{updated_bookmark}/#{bookmark_count} bookmarks were updated."
  end

end
