require 'rails_helper'

RSpec.describe Email, type: :model do
  it { is_expected.to belong_to :user }

  it { is_expected.to validate_presence_of :from }
  it { is_expected.to validate_presence_of :to }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :text }

  describe 'deliver now' do
    it 'calls mailgun api' do
      email = build_stubbed(:email)

      expect_any_instance_of(Mailer::Client).to receive(:from).with(email.from)
      expect_any_instance_of(Mailer::Client).to receive(:to).with(email.to)
      expect_any_instance_of(Mailer::Client).to receive(:subject).with(email.subject)
      expect_any_instance_of(Mailer::Client).to receive(:text).with(email.text)
      expect_any_instance_of(Mailer::Client).to receive(:deliver_now)

      email.deliver_now
    end
  end
end
