source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.4'

# Rails 8.1
gem 'rails', '~> 8.1.0'

# Ruby 3.4 compatibility - these gems are being removed from stdlib
gem 'mutex_m'
gem 'drb'
gem 'observer'

# gem 'annotate', '~> 3.2'  # Commented out - not compatible with Rails 8.0 yet
gem 'bootsnap', '>= 1.4.3', require: false
# Devise - PR #5340 merged, using official gem now
gem 'devise', '~> 4.9'
gem 'draper', '~> 4.0'
gem 'geocoder'
gem 'haml-rails'
# Hotwire - using separate gems instead of hotwire-rails
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'image_processing'
gem 'jbuilder', '~> 2.11'
gem 'ldap_lookup'
gem 'nokogiri', '~> 1.18.9'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1.3'
gem 'order_as_specified', '~> 1.7'
gem 'pagy', '~> 6.0'  # Pin to 6.x for compatibility with current config
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search'
gem 'puma', '~> 6.0'
gem 'pundit', '~> 2.3'
gem 'redis', '~> 4.8', '>= 4.8.1'
gem 'responders', '~> 3.1'
gem 'sassc-rails'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sidekiq', '~> 7.1.3'
gem 'skylight'
gem 'stackprof'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'jsbundling-rails'
gem 'cssbundling-rails'

group :development, :test do
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop-performance'
  gem 'standard'
end

group :development do
  gem 'erb2haml'
  gem 'letter_opener_web', '~> 2.0'
  gem 'pry-rails'
  gem 'web-console', '>= 4.1.0'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker', '~> 2.19'
  gem 'ffaker'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
end
