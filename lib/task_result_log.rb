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
