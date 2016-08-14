# Preview all emails at http://localhost:3000/rails/mailers/import_mailer
class ImportMailerPreview < ActionMailer::Preview
  def delicious_finish_all_imported
    ImportMailer.delicious_finish(User.first, 14, 14, [])
  end

  def delicious_finish_some_errors
    ImportMailer.delicious_finish(User.first, 14, 12, ["error 1", "error 2"])
  end

  def delicious_finish_nothing_imported
    errors = 14.times.map do |error|
      "http://www.google.fr/#{error}: URL has already been taken"
    end
    
    ImportMailer.delicious_finish(User.first, 14, 0, errors)
  end
end
