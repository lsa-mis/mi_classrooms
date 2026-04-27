require "json"

class AuthTokenApi
  def initialize(scope)
    @scope = scope
  end

  def get_auth_token
    UmApi.token_store.fetch(@scope)
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

  def update_log(message, debug, payload = nil)
    status =
      if debug
        "error"
      else
        "success"
      end
    result = message.dup
    if payload.present?
      result += "\r\n\r\nStructured report:\r\n"
      result += JSON.pretty_generate(payload)
    end
    record = ApiUpdateLog.new(result: result, status: status)
    unless record.save
      # write it to the log
      @log.api_logger.debug "api_update_log, error: Could not save: record.errors.full_messages"
    end
  end
end
