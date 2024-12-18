# Load the Rails application.
require_relative "application"

require "./lib/api_log"
require "./lib/auth_token_api"
require "./lib/buildings_api"
require "./lib/classroom_api"
require "./lib/department_api"
require "./lib/task_result_log"

# Initialize the Rails application.
Rails.application.initialize!
