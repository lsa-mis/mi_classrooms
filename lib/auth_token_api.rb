require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class AuthTokenApi
  BASE_URL = "https://gw.api.it.umich.edu/um/oauth2/token"

  def initialize(scope)
    @scope = scope
    @logger = ApiLog.instance.logger
  end

  def get_auth_token
    response_json = request_auth_token

    # puts "AuthTokenApi::get_auth_token #{response_json }"

    if response_json['access_token']
      success_response(response_json['access_token'])
    else
      error_response(response_json['fault']&.fetch('faultstring', 'Unknown error'))
    end
  rescue StandardError => e
    log_error("AuthTokenApi Error: #{e.message}")
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

  def log_error(message)
    @logger.debug(message)
    @debug = true
  end
end

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