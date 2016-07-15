require 'rails_helper'

describe Mailer::Client do
  describe "deliver_now" do
    before(:each) { WebMock.stub_request(:any, /https:\/\/api.mailgun.net.*/) }

    it "calls Mailgun API" do
      email = build_stubbed(:email)
      client = Mailer::Client.new
      client.from(email.from)
      client.to(email.to)
      client.subject(email.subject)
      client.text(email.text)
      client.deliver_now

      expect(WebMock).to have_requested(:post, "https://api.mailgun.net/v3/#{Settings.mailgun.domain}/messages").
      with(body: {
        from: [email.from],
        "o:tracking-clicks": ["yes"],
        subject: [email.subject],
        text: [email.text],
        to: [email.to]
      })
    end
  end
end
