class EveryUserFollowEveryUser < ActiveRecord::Migration
  def up
    say_with_time("Make every user follow every other user") do
      users = User.all
      ActiveRecord::Base.transaction do
        pbar = ProgressBar.create(:title => "Loop on every users", :starting_at => 0, :total => users.size)
        users.each do |user|
          users.each do |user_to_follow|
            if user_to_follow.id != user.id
              user.follow(user_to_follow)
            end
          end
          pbar.increment
        end
      end
    end
  end

  def down
    raise IrreversibleMigration
  end
end
