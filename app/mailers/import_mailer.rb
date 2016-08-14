class ImportMailer < ApplicationMailer
  def delicious_finish(user, total_bookmarks, imported_bookmarks, invalid_bookmarks)
    @name = user.user_profile.name
    @total_bookmarks = total_bookmarks
    @imported_bookmarks = imported_bookmarks
    @invalid_bookmarks = invalid_bookmarks

    mail(from: Settings.mailgun.from, to: user.email, bcc: Settings.mailgun.admin_notification_address, subject: I18n.t("mailers.import_mailer.delicious_finish.subject")) do |format|
      format.mjml
    end
  end
end
