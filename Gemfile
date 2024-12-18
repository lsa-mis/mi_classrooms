source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.4'

gem 'annotate', '~> 3.2.0'
gem 'bootsnap', '>= 1.4.3', require: false
gem 'devise', github: 'ghiculescu/devise', branch: 'error-code-422' # https://github.com/heartcombo/devise/pull/5340 not yet merged
gem 'draper', '~> 4.0'
gem 'geocoder'
gem 'haml-rails'
gem 'hotwire-rails'
gem 'image_processing'
gem 'jbuilder', '~> 2.7'
gem 'ldap_lookup'
gem 'listen'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1'
gem 'order_as_specified', '~> 1.7'
gem 'pagy', '~> 6.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search'
# gem "poppler", "~> 4.1", ">= 4.1.8"
gem 'mutex_m'

gem 'drb'
gem 'puma', '5.6.8'
gem 'pundit'
gem 'rails', '~> 7.0.0'
gem 'redis', '~> 4.8', '>= 4.8.1'
gem 'responders', github: 'heartcombo/responders'
gem 'sidekiq', '~> 7.1.3'
gem 'skylight'
gem 'sprockets-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'uglifier'

gem 'turbo-rails'

gem 'importmap-rails', '~> 2.0'
gem 'stimulus-rails'

group :development, :test do
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rspec-rails', '~> 5.0', '>= 5.0.2'
  gem 'rubocop-performance'
  gem 'standard'
end

group :development do
  gem 'erb2haml'
  gem 'letter_opener_web', '~> 2.0'
  gem 'pry-rails'
  # gem "spring"
  # gem "spring-watcher-listen"
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

gem 'tailwindcss-rails', '~> 2.5'

gem 'bigdecimal', '~> 3.1'
