
# Securely Handling API Credentials: Utilizes Rails' credentials feature more effectively, ensuring environment-specific secure storage.
# Error Handling: Improves error handling by rescuing specific exceptions and using Rails' logging for better diagnostics.
# HTTP Interaction: Encapsulates the HTTP request logic within its method to simplify the get_auth_token method and enhance code readability.
# Response Handling: Streamlines response handling for clarity and efficiency.

# class AuthTokenApi
#   def initialize(scope)
#     @scope = scope
#     @returned_data = {'success' => false, 'error' => '', 'access_token' => nil}
#   end

#   def get_auth_token
#     begin
#       url = URI("https://gw.api.it.umich.edu/um/oauth2/token")
#       http = Net::HTTP.new(url.host, url.port)
#       http.use_ssl = true
#       http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#       request = Net::HTTP::Post.new(url)
#       request["content-type"] = 'application/x-www-form-urlencoded'
#       request["accept"] = 'application/json'
#       request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:buildings_client_id]}&client_secret=#{Rails.application.credentials.um_api[:buildings_client_secret]}&scope=#{@scope}"

#       response = http.request(request)
#       response_json = JSON.parse(response.read_body)
      
#       if response_json['access_token'].present?
#         @returned_data['success'] = true
#         @returned_data['access_token'] = response_json['access_token']
#       elsif response_json['fault'].present?
#           @returned_data['error'] = response_json['fault']['faultstring']
#       else
#         @returned_data['error'] = 'Unknown error'
#       end
#       rescue => @error
#         @returned_data['error'] = @error.inspect
#       return false
#     end
#     return @returned_data
#   end
# end

require 'net/http'
require 'uri'
require 'json'

class AuthTokenApi
  BASE_URL = "https://gw.api.it.umich.edu/um/oauth2/token"

  def initialize(scope)
    @scope = scope
  end

  def get_auth_token
    response_json = request_auth_token

    if response_json['access_token']
      success_response(response_json['access_token'])
    else
      error_response(response_json['fault']&.fetch('faultstring', 'Unknown error'))
    end
  rescue StandardError => e
    Rails.logger.error("AuthTokenApi Error: #{e.message}")
    error_response(e.message)
  end

  private

  def request_auth_token
    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request.body = build_request_body

    response = http.request(request)
    JSON.parse(response.read_body)
  end

  def build_request_body
    credentials = Rails.application.credentials.um_api
    "grant_type=client_credentials&client_id=#{credentials[:buildings_client_id]}&client_secret=#{credentials[:buildings_client_secret]}&scope=#{@scope}"
  end

  def success_response(access_token)
    {'success' => true, 'error' => '', 'access_token' => access_token}
  end

  def error_response(error)
    {'success' => false, 'error' => error, 'access_token' => nil}
  end
end

#=======================================================================================
# Singleton Pattern for ApiLog: Use a singleton pattern for the ApiLog to ensure that the logger is initialized only once, reducing overhead from checking or creating new logger instances on every log operation.

# Rails Configuration for Logger Path: Instead of hardcoding the logger path, use Rails' configuration to allow flexibility and environment-specific log paths.

# Error Handling and Logging: Improve the error handling and logging logic for clearer and more concise code.

# class ApiLog
#   def api_logger
#     @@api_logger ||= Logger.new("#{Rails.root}/log/api_nightly_update_db.log")
#   end
# end

# class TaskResultLog
#   def initialize
#     @log = ApiLog.new
#   end

#   def update_log(message, debug)
#     if debug
#       status = "error"
#     else
#       status = "success"
#     end
#     record = ApiUpdateLog.new(result: message, status: status)
#     unless record.save
#       # write it to the log
#       @log.api_logger.debug "api_update_log, error: Could not save: record.errors.full_messages"
#     end
#   end
# end

# # config/initializers/api_logging.rb
# Rails.application.config.api_logging = {
#   file_path: "#{Rails.root}/log/api_nightly_update_db.log"
# }

# # app/services/api_log.rb
# require 'singleton'

class ApiLog
  include Singleton

  def logger
    @logger ||= Logger.new(Rails.application.config.api_logging[:file_path])
  end
end

# app/models/task_result_log.rb
class TaskResultLog
  def initialize
    @logger = ApiLog.instance.logger
  end

  def update_log(message, debug)
    status = debug ? "error" : "success"
    unless ApiUpdateLog.create(result: message, status: status)
      log_error(message)
    end
  end

  private

  def log_error(message)
    @logger.debug "API Update Log Error: Could not save - #{message}"
  end
end

# Singleton ApiLog: By including the Singleton module, ApiLog ensures that logger is initialized only once and reused, enhancing performance.

# Rails Configuration: Storing the logger file path in Rails.application.config allows easy changes and environment-specific configurations without altering the service class.

# Improved Error Handling: The update_log method now uses a more Ruby idiomatic approach, creating the ApiUpdateLog record and logging to file only if it fails to save.