source 'https://rubygems.org'
ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use Puma as webserver
gem 'puma'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Migration progress bar
gem 'ruby-progressbar'

# Authentication
gem 'devise', '~> 4.1'
# Authorizations
gem 'pundit', '~> 1.1'

# Bootstrap
gem 'bootstrap-sass', '~> 3.3'
gem 'font-awesome-rails'
gem 'material_icons'

# Tags
gem 'acts-as-taggable-on', '~> 3.4'

# Config cross environment
gem 'config'

# Send email with mailgun
gem 'mailgun_rails'

# Slack notifications
gem 'slack-notifier'

# ActiveJobs
gem 'sidekiq', '~> 4.1'
gem 'redis-namespace'

# Config cron jobs
gem 'whenever', :require => false

# Analytics
gem 'ahoy_matey'

# Full text search
gem 'pg_search'
# Add where.or search capacities
gem 'where-or'

# Transform text to html
gem 'rinku'

# Embed inline svg
gem 'inline_svg'

# Use MJML for email
gem 'mjml-rails'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'

# Follow users
gem 'acts_as_follower'

# Countries
gem 'country_select'

# Validators
gem 'date_validator'
gem 'validate_url'

# Upload files
gem 'carrierwave', '>= 1.0.0.beta', '< 2.0'
gem 'mini_magick', '~> 4.5'

# Handle meta-tags
gem 'meta-tags'

# Detect browsers
gem "browser"

# HTML parsing
gem "nokogiri"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Clean DB for tests
  gem 'database_cleaner'
  # Fake nice data for tests
  gem 'faker'
  # Testing framework
  gem 'rspec-rails', '~> 3.4'
  # Create test data instead of fixtures
  gem 'factory_girl'
  # Freeze or travel in time
  gem 'timecop'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Watches code files & executes tests
  gem 'guard-rspec'
  # Lunch rake tasks via guard
  gem 'guard-rake'
  #  Display test results in a OSX notification
  # gem 'terminal-notifier-guard', '~> 1.6.1'
  # Don't log static file requests
  gem 'quiet_assets'
  # Get a better Rails error page
  # gem 'better_errors'
  # gem 'binding_of_caller'
  # gem 'meta_request'

  gem 'capistrano',         require: false
  gem 'capistrano-rbenv',   require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-sidekiq', require: false
end

group :test do
  # Shortcuts for testing model validations and more
  gem 'shoulda-matchers', require: false
  # RSpec matchers for testing Pundit authorisation policies
  gem 'pundit-matchers', '~> 1.1.0'
  # Validate JSON format
  gem 'json_spec'
  # Record and replay HTTP calls during tests
  gem 'vcr'
  # Mock HTTP calls during tests
  gem 'webmock'
  # Feature tests
  gem 'capybara'
  gem 'capybara-email'
end

group :production do
  # Rails 12factor, Based on the ideas behind 12factor.net
  gem 'rails_12factor'
end
