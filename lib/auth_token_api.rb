class AuthTokenApi
  OK_CODE = "200"

  def initialize(scope)
    @scope = scope
    @access_token = false
  end

  def get_auth_token
    begin
      url = URI("https://gw.api.it.umich.edu/um/oauth2/token")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request["content-type"] = 'application/x-www-form-urlencoded'
      request["accept"] = 'application/json'
      request.body = "grant_type=client_credentials&client_id=#{Rails.application.credentials.um_api[:buildings_client_id]}&client_secret=#{Rails.application.credentials.um_api[:buildings_client_secret]}&scope=#{@scope}"

      response = http.request(request)
      puts response
      response_json = JSON.parse(response.read_body)
      puts response_json
      if response.code == OK_CODE && response_json['access_token'].present?
        @access_token = response_json['access_token']
      else
        if response_json['fault'].present?
          error = response_json['fault']['faultstring']
        else
          error = 'Unknown error'
        end
        log = ApiLog.new
        log.api_logger.debug "get access token for #{@scope}, error: No access_token - #{error}"
        task_result = TaskResultLog.new
        task_result.update_log_table(message: "get access token for #{@scope}, error: No access_token - #{error}", debug: false)
      end
      rescue => @error
        log.api_logger.debug "get access token for #{@scope}, error: No access_token - #{@error.inspect}"
        task_result.update_log_table(message: "get access token for #{@scope}, error: No access_token - #{@error.inspect}", debug: false)
      return false
    end
    return @access_token
  end
end

class ApiLog
  def api_logger
    @@api_logger ||= Logger.new("#{Rails.root}/log/api_nightly_update_db.log")
  end
end

class TaskResultLog
  def initialize
    @log = ApiLog.new
  end

  def update_log_table(message:, debug:)
    if debug
      status = "error"
    else
      status = "success"
    end
    record = ApiUpdateLog.new(result: message, status: status)
    unless record.save
      # write it to the log
      @log.api_logger.debug "api_update_log_table, error: Could not save: record.errors.full_messages"
    end
  end

  def update_log_table_with_errors(task:, task_time:, status_report:)
    status_report << "#{task} failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    @log.api_logger.debug "#{message}"
    update_log_table(message: message, debug: true)
  end

end
