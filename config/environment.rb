# Load the Rails application.
require_relative "application"

require "./lib/um_api"
require "./lib/api_update_database/phase_result"
require "./lib/api_update_database/run_result"
require "./lib/auth_token_api"
require "./lib/buildings_api"
require "./lib/classroom_api"
require "./lib/department_api"
require "./lib/api_update_database/runner"

# Initialize the Rails application.
Rails.application.initialize!
