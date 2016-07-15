require 'mailgun'

class Mailer::Client
  def initialize
    @mg_client = Mailgun::Client.new Rails.application.secrets.mailgun_api_key
    @domain = Settings.mailgun.domain
  end

  def from(from)
    @from = from
  end

  def to(to)
    @to = to
  end

  def subject(subject)
    @subject = subject
  end

  def text(text)
    @text = text
  end

  def body(body)
    @body = body
  end

  def attachments(attachments)
    @attachments = attachments
  end

  def delivery_time(time)
    @delivery_time = time
  end

  # Send email
  def deliver_now
    message = get_message
    @mg_client.send_message @domain, get_message
  end

  private

  def get_message
    message = Mailgun::MessageBuilder.new
    message.from(@from || Settings.mailgun.from)
    message.add_recipient(:to, @to)
    message.subject(@subject)
    message.body_text(@text) if @text
    message.body_html(@body) if @body
    if @attachments.present?
      @attachments.each do |attachment|
        message.add_attachment(attachment)
      end
    end
    message.set_delivery_time(@delivery_time) if @delivery_time
    message.track_clicks(true)
    message
  end
end
