source 'https://rubygems.org'


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

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Authentication
gem 'devise'

# Authorizations
gem "pundit"

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
  gem 'terminal-notifier-guard', '~> 1.6.1'
  # Don't log static file requests
  gem 'quiet_assets'
  # Get a better Rails error page
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
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
end
