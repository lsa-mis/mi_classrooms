class AuthTokenApi
  OK_CODE = "200"

  def initialize(scope)
    @scope = scope
    @access_token = false
    @log = ApiLog.new
    @task_result = TaskResultLog.new
  end

  def get_auth_token
    begin
      response = http_call
      response_json = JSON.parse(response.read_body)
      if response.code == OK_CODE && response_json['access_token'].present?
        @access_token = response_json['access_token']
      else
        if response_json['fault'].present?
          error = response_json['fault']['faultstring']
        else
          error = 'Unknown error'
        end
        @log.api_logger.debug "get access token for #{@scope}, error: No access_token - #{error}"
        @task_result.update_log_table(message: "get access token for #{@scope}, error: No access_token - #{error}", debug: true)
      end
    rescue => @error
      @log.api_logger.debug @error.message
      @task_result.update_log_table(message: @error.message, debug: true)
      return false
    end
    return @access_token
  end

  def http_call
    url = URI("https://gw.api.it.umich.edu/um/oauth2/token")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["accept"] = 'application/json'
    request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:buildings_client_id]}&client_secret=#{Rails.application.credentials.um_api[:buildings_client_secret]}&scope=#{@scope}"

    response = http.request(request)
  end
end
