require 'rails_helper'

RSpec.describe SlackNotifierJob, type: :job do
  include ActiveJob::TestHelper

  let(:user_profile) { create(:user_profile) }
  let(:bookmark) { create(:bookmark, user: user_profile.user) }

  subject(:job) { described_class.perform_later("new_bookmark", bookmark) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in low queue' do
    expect(SlackNotifierJob.new.queue_name).to eq('low')
  end

  it 'calls slack webhook' do
    WebMock.stub_request(:any, /https:\/\/hooks.slack.com.*/)

    perform_enqueued_jobs { job }

    attachment = {
      "author_name" => user_profile.name,
      "author_link" => "https://wundermarks.com/profile/#{user_profile.id}",
      "title" => bookmark.title,
      "title_link" => bookmark.url,
      "text" => bookmark.description,
      "ts" => bookmark.created_at.to_i,
      "color" => 'good'
    }

    expect(WebMock).to have_requested(:post, Settings.slack_notifier.webhook_url).
    with(:body => {
      "payload" => {
        "attachments" => [attachment],
        "text" => "New bookmark from #{bookmark.user.user_profile.name}: #{bookmark.url}"
      }.to_json
    })
  end
end
