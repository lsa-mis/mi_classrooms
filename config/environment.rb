# Load the Rails application.
require_relative "application"

require "./lib/auth_token_api"
require "./lib/buildings_api"
require "./lib/classroom_api"
require "./lib/department_api"

# Initialize the Rails application.
Rails.application.initialize!
