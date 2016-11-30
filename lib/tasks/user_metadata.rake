namespace :user_metadata do
  desc "Reset metadata for every users"
  task reset_every_user_metadata: :environment do
    puts "Start to reset every user metadata"
    users = User.all
    user_counts = users.size

    puts "Found #{user_counts} users."

    updated_users = 0
    ActiveRecord::Base.transaction do
      users.each do |user|
        UserMetadataUpdater.reset_user_metadatum(user)
        updated_users += 1
      end
    end

    puts "End of reset. #{updated_users}/#{user_counts} user's metadata were reseted."
  end

end
