source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.4"

gem "annotate"
gem "bootsnap", ">= 1.4.3", require: false
gem "devise"
gem "draper", "~> 4.0"
gem "geocoder"
gem "haml-rails"
gem "hotwire-rails"
gem "image_processing"
gem "importmap-rails"
gem "jbuilder", "~> 2.7"
gem "ldap_lookup"
gem "listen"
gem "nokogiri", "~> 1.18.4"
gem "observer"
gem "omniauth-google-oauth2"
gem "omniauth-saml", "~> 2.1.3"
gem "omniauth-rails_csrf_protection"
gem "order_as_specified", "~> 1.7"
gem "pagy"
gem "pg", ">= 0.18", "< 2.0"
gem "pg_search"
# gem "poppler", "~> 4.1", ">= 4.1.8"
gem "puma", "5.6.9"
gem "pundit"
gem "rails", "~> 7.2.2"
# gem "redis", "~> 5.0", ">= 5.0.6"
gem 'redis', '~> 4.8', '>= 4.8.1'
gem "responders", github: "heartcombo/responders"
gem "sassc-rails"
gem "sidekiq", "~> 7.1.3"
gem "skylight"
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem "bullet"
  gem "factory_bot_rails"
  gem "pry"
  gem "rspec-rails", "~> 5.0", ">= 5.0.2"
  gem "rubocop-performance"
  gem "standard"
end

group :development do
  gem "erb2haml"
  gem "letter_opener_web", "~> 2.0"
  gem "pry-rails"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "faker", "~> 2.19"
  gem "ffaker"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end
