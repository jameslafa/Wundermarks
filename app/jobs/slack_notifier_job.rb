require 'slack-notifier'

class SlackNotifierJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  queue_as :low

  def perform(notification_type, resource)
    notifier = Slack::Notifier.new Settings.slack_notifier.webhook_url

    if notification_type == "new_bookmark"
      message = "New bookmark from #{resource.user.user_profile.name}: #{resource.url}"

      bookmark_attachment = {
        author_name: resource.user.user_profile.name,
        author_link: url_for(controller: 'user_profiles', action: 'show', id: resource.user.user_profile.id),
        title: resource.title,
        title_link: url_for(controller: 'bookmarks', action: 'show', id: resource.id),
        text: resource.description,
        ts: resource.created_at.to_i,
        color: 'good'
      }

      notifier.ping Slack::Notifier::LinkFormatter.format(message), attachments: [bookmark_attachment]

    elsif notification_type == "new_user_registration"
      message = "New User registration: #{resource.user_profile.name}: #{resource.email}"
      notifier.ping Slack::Notifier::LinkFormatter.format(message)

    end
  end
end
