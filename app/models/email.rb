class Email < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :from, :to, :subject, :text

  # Send the email synchronously using the mailgun
  def deliver_now
    client = Mailer::Client.new

    client.from(from)
    client.to(to)
    client.subject(subject)
    client.body(body) if body.present?
    client.text(text) if text.present?

    client.deliver_now
  end
end
