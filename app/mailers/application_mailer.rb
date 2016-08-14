class ApplicationMailer < ActionMailer::Base
  default from: Settings.mailgun.from
  layout 'mailer'
end
