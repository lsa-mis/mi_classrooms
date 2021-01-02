source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

# Bundle edge Rails instead:
gem "rails", "6.1.0"
# gem "rails", "~> 6.0.3"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem "webpacker", git: "https://github.com/rails/webpacker.git"
gem "webpacker", "~> 5.2.1"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.3", require: false
# gem "administrate", "~> 0.8.1"
gem "haml-rails"
gem "sassc-rails"
gem "sidekiq", "~> 6.1.0"
gem "uglifier"
gem "geocoder"
gem "pagy"
gem "pg_search"
# gem "gravatar_image_tag", github: "mdeering/gravatar_image_tag"
gem "listen"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "pry"
  gem "factory_bot_rails"
  gem "annotate", "~> 3.1.1"
  gem "standard"
  gem "rubocop-performance"
end

group :development do
  gem "web-console", ">= 3.3.0"
  # Invoke rake tasks on remote server.
  # example use: cap staging    invoke:rake TASK=db:seed
  gem "capistrano",         require: false
  gem "capistrano-rbenv",   require: false
  gem "capistrano-postgresql"
  gem "capistrano-rails",   require: false
  gem "capistrano-bundler", require: false
  gem "capistrano3-puma", "~> 4.0", require: false
  gem "erb2haml"
  gem "pry-rails"
  gem "spring"
  gem "spring-watcher-listen"
end

group :test do
  gem "capybara"
  gem "webdrivers"
  gem "shoulda-matchers"
  gem "ffaker"
  gem "database_cleaner"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "devise"
gem "omniauth-google-oauth2"