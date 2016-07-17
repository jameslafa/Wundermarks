# encoding: utf-8

##
# Backup Generated: mercury_files
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t mercury_files [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
Model.new(:wundermarks_database, 'Backup wundermarks database') do
  environment = ENV['RAILS_ENV']

  unless environment
    raise "Please set the variable RAILS_ENV while executing the command line"
  end

  application_root_path = "/home/deploy/apps/wundermarks_#{environment}"
  db_config = YAML.load_file("#{application_root_path}/current/config/database.yml")[environment]

  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = db_config['database']
    db.username           = db_config['username']
    db.password           = ENV["#{environment.upcase}_DB_PASSWORD"]
    db.host               = "localhost"
    db.port               = 5432
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    # db.skip_tables        = ['skip', 'these', 'tables']
    # db.only_tables        = ['only', 'these' 'tables']
    db.additional_options = ["-xc", "-E=utf8"]
  end

  compress_with Bzip2
  store_with FTP
  notify_by Slack
  encrypt_with OpenSSL
end
