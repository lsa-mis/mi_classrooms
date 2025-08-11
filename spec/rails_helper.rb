# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Disable Pundit authorization checking in controller and request tests
  config.before(:each, type: :controller) do
    allow_any_instance_of(ApplicationController).to receive(:verify_authorized).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:verify_policy_scoped).and_return(true)
  end

  config.before(:each, type: :request) do
    allow_any_instance_of(ApplicationController).to receive(:verify_authorized).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:verify_policy_scoped).and_return(true)
  end

  # For system specs, bypass auth and authorization for UI flows
  config.before(:each, type: :system) do
    test_user = FactoryBot.build(:user, email: 'test@example.com')
    test_user.admin = true
    test_user.membership = ['mi-classrooms-non-admin-staging']

    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(test_user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:verify_authorized).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:verify_policy_scoped).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end
  
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Capybara.javascript_driver = ENV['SHOW_BROWSER'] ? :selenium_chrome : :selenium_chrome_headless
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end