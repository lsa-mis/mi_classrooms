# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Framework
gem 'bootsnap', '>= 1.4.3', require: false
gem 'rails', '~> 8.1.0'

# Frontend / UI
gem 'importmap-rails', '~> 2.2'
gem 'jbuilder', '~> 2.11'
gem 'sassc-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails', '~> 4.0'
gem 'turbo-rails'

# Data / persistence
gem 'order_as_specified', '~> 1.7'
gem 'pagy', '~> 6.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'pg_search'
gem 'puma', '~> 7.2'
gem 'solid_cable', '~> 3.0'
gem 'solid_queue', '~> 1.2'

# Auth / authorization
gem 'devise', '~> 5.0'
gem 'ldap_lookup'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml', '~> 2.1.3'
gem 'pundit', '~> 2.3'
gem 'responders', '~> 3.1'

# Monitoring / profiling
gem 'mission_control-jobs', '~> 1.1'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'skylight'
gem 'stackprof'

# Application features
gem 'draper', '~> 4.0'
gem 'geocoder'
gem 'image_processing'
gem 'lsa_tdx_feedback'
gem 'nokogiri', '~> 1.19.1'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Ruby 4.0 compatibility (extracted from stdlib)
gem 'benchmark'
gem 'drb'
gem 'mutex_m'
gem 'observer'
gem 'ostruct'

group :development, :test do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop-performance'
  gem 'standard'
end

group :development do
  gem 'letter_opener_web', '~> 2.0'
  gem 'pry-rails'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'faker', '~> 2.19'
  gem 'ffaker'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.22.0'
end
