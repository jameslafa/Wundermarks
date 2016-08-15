class DeliciousImporterJob < ActiveJob::Base
  queue_as :low

  def perform(user, file_path)
    Rails.logger.debug("Import for user [#{user.id}] file #{file_path}")
    # Open pseudo shitty html/xml file from delicious
    # Tags are not closed, it's a freaking mess
    file = File.open(file_path) { |f| Nokogiri::HTML(f) }

    # We look for A tags. We have to drop the DD containing the description, it's impossible to parse them.
    links = file.xpath("//a")
    Rails.logger.debug("Found #{links.size} links")

    # We store the number of imported bookmarks
    imported_bookmarks_count = 0
    delicious_bookmarks_count = links.count

    # We store the list of bookmarks we couldn't import
    invalid_bookmarks = []

    ActiveRecord::Base.transaction do
      # We look on every links
      links.each do |link|
        url = link.attr("href")

        # Time is stored as a unix timestamp
        created_at =  DateTime.strptime(link.attr("add_date"),'%s')

        # Extract tags: guess what it's also a mess. But acts-as-taggable-on should clean it.
        # We also take only the first 5 ones, because we limit tags to 5 on Wundermarks
        tag_list = ActsAsTaggableOn::TagList.new.add(link.attr("tags"), parse: true).take(5)

        # Extract the title, truncate it
        title =  link.content.truncate(Bookmark::MAX_TITLE_LENGTH)

        # On Delicious, it's either private or public. PRIVATE == "1" means private.
        privacy = link.attr("private").to_bool ? "only_me" : "everyone"

        # Build a new bookmark
        bookmark = Bookmark.new(user: user, url: url, created_at: created_at, title: title, privacy: privacy, source: 'delicious')

        # Add the tag list
        bookmark.tag_list.add(tag_list)

        # Save the bookmark
        if bookmark.save
          # Increment the counter if valid
          imported_bookmarks_count += 1
        else
          # Save the error if invalid
          invalid_bookmarks << "#{bookmark.url}: #{bookmark.errors.full_messages.join(", ")}"
        end
      end
    end

    # Notify the user per email
    ImportMailer.delicious_finish(user, delicious_bookmarks_count, imported_bookmarks_count, invalid_bookmarks).deliver_now
  end
end
