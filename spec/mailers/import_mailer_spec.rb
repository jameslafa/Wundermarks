require "rails_helper"

RSpec.describe ImportMailer, type: :mailer do
  describe 'delicious_finish' do
    let(:user_profile) { create(:user_profile) }
    let(:user) { user_profile.user }

    let(:mail) { described_class.delicious_finish(user, 10, 10, []).deliver_now }

    it 'sets the subject' do
      expect(mail.subject).to eq I18n.t("mailers.import_mailer.delicious_finish.subject")
    end

    it 'sends it from james' do
      expect(mail.header[:from].to_s).to eq Settings.mailgun.from
    end

    it 'sends it to the user' do
      expect(mail.to).to match_array [user.email]
    end

    it 'sends it to the admin as bcc' do
      expect(mail.bcc).to match_array [Settings.mailgun.admin_notification_address]
    end


    context 'with all bookmarks imported' do
      let!(:mail) { described_class.delicious_finish(user, 10, 10, []).deliver_now }

      it 'show the right content' do
        open_email(user.email)
        expect(current_email).to have_content "Hello #{user_profile.name}"
        expect(current_email).to have_content "Congratulations, all your 10 bookmarks have been imported to Wundermarks!"
        expect(current_email).to have_content "You can now see your imported bookmarks."
        expect(current_email).to have_link("your imported bookmarks", href: "https://wundermarks.com/bookmarks?post_import=delicious")
      end
    end

    context 'with some bookmarks imported' do
      let!(:mail) { described_class.delicious_finish(user, 10, 9, ["http://google.fr: URL has been already taken"]).deliver_now }

      it 'show the right content with the error list' do
        open_email(user.email)
        expect(current_email).to have_content "Hello #{user_profile.name}"
        expect(current_email).to have_content "Congratulations, we have imported 9 of your bookmarks to Wundermarks!"
        expect(current_email).to have_content "You can now see your imported bookmarks."
        expect(current_email).to have_link("your imported bookmarks", href: "https://wundermarks.com/bookmarks?post_import=delicious")
        expect(current_email).to have_content "1 of your bookmarks was not imported:"
        expect(current_email).to have_content "http://google.fr: URL has been already taken"
        expect(current_email).to have_content "You can either add them manually or send us an email to #{Settings.mailgun.admin_email_address} and we will help you!"
        expect(current_email).to have_link(Settings.mailgun.admin_email_address, href: "mailto:#{Settings.mailgun.admin_email_address}")
      end
    end

    context 'with no bookmark imported' do
      let!(:mail) { described_class.delicious_finish(user, 2, 0, ["http://google.fr: URL has been already taken", "http://google.com: URL has been already taken"]).deliver_now }

      it 'show the right content with the error list' do
        open_email(user.email)
        expect(current_email).to have_content "Hello #{user_profile.name}"
        expect(current_email).to have_content "Unfortunately, we could not import any of your bookmarks. If you think the file you submitted was correct, please contact us at #{Settings.mailgun.admin_email_address} and we will help you."
        expect(current_email).to have_link(Settings.mailgun.admin_email_address, href: "mailto:#{Settings.mailgun.admin_email_address}")
        expect(current_email).to have_content "We have encountered the following errors:"
        expect(current_email).to have_content "http://google.fr: URL has been already taken"
        expect(current_email).to have_content "http://google.com: URL has been already taken"
      end
    end
  end
end
