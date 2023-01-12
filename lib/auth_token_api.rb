class AuthTokenApi
  def initialize(type, scope)
    @type = type
    @scope = scope
    @returned_data = {'success' => false, "error" => "", 'access_token' => nil}
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
      if JSON.parse(response.read_body)['error'].present?
        @returned_data['error'] = JSON.parse(response.read_body)['error']
      else
        @returned_data['success'] = true
        @returned_data['access_token'] = JSON.parse(response.read_body)['access_token']
      end
      rescue => @error
        @returned_data['error'] = @error.inspect
      return false
    end
    return @returned_data
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

  def update_log(message, debug)
    if debug
      status = "error"
    else
      status = "success"
    end
    record = ApiUpdateLog.new(result: message, status: status)
    unless record.save
      # write it to the log
      @log.api_logger.debug "api_update_log, error: Could not save: record.errors.full_messages"
    end
  end
end