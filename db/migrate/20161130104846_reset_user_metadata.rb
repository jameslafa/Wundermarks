class ResetUserMetadata < ActiveRecord::Migration
  def up
    Rake::Task['user_metadata:reset_every_user_metadata'].invoke
  end
end
