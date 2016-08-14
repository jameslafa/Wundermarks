require 'rails_helper'

RSpec.describe DeliciousImporterJob, type: :job do
  include ActiveJob::TestHelper

  let(:user_profile) { create(:user_profile) }
  let(:user) { user_profile.user }

  subject(:job) { described_class.perform_later(user, Rails.root.join('spec', 'fixtures', 'files', 'delicious_export.html').to_s) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in low queue' do
    expect(DeliciousImporterJob.new.queue_name).to eq('low')
  end

  it 'imports the bookmarks valid bookmarks' do
    user_bookmark_counts = user.bookmarks.count

    # It should import only 6 bookmarks, the 7th is duplicated
    expect{
      perform_enqueued_jobs { job }
    }.to change(Bookmark, :count).by(6)

    expect(user.bookmarks.count).to eq (user_bookmark_counts + 6)

    expect(user.bookmarks.first.title).to eq "Squash several Git commits into a single commit - makandropedia, I'm adding s..." # only 80 chars
    expect(user.bookmarks.first.source).to eq "delicious"
    expect(user.bookmarks.first.tag_list).to eq ["git", "squash", "rebase"]
    expect(user.bookmarks.second.tag_list).to eq ["debug", "request", "post", "get", "http"] # only first 5
  end

  describe 'email notification' do
    it 'enqueues an email to notify the user' do
      expect{
        perform_enqueued_jobs { job }
      }.to change {ActionMailer::Base.deliveries.count}.by(1)
    end

    it 'calls the mailer with the right parameters' do
      message = double('Message')
      expect(message).to receive(:deliver_now)

      args = [user, 7, 6, ["https://github.com/aykamko/tag: URL has already been bookmarked"]]
      expect(ImportMailer).to receive(:delicious_finish).with(*args).and_return(message)

      perform_enqueued_jobs { job }
    end
  end
end
