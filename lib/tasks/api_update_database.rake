# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

desc "This will update Classrooms database using APIs"
task api_update_database: :environment do
  log = ApiLog.instance
  errors = []
  status_report = []
  task_time = 0
  @debug = false
  task_result = TaskResultLog.new

  def get_auth_token(api_type)
    auth_token = AuthTokenApi.new(api_type)
    result = auth_token.get_auth_token
    if result['success']
      [true, result['access_token']]
    else
      [false, result['error']]
    end
  end

  def update_api_data(api, action_name, log_message, total_time)
    start_time = Benchmark.measure {
      @debug = api.send(action_name)
    }
    elapsed_time = start_time.real.round(2)
    puts "#{log_message} Time: #{elapsed_time} seconds"
    total_time += (elapsed_time / 60) % 60
    [total_time, @debug]
  end

  # Update process for each API action
  # [['buildings', 'update_campus_list'], ['buildings', 'update_all_buildings'], ['buildings', 'update_rooms'], ['classroom', 'add_facility_id_to_classrooms'], ['classroom', 'update_all_classroom_characteristics'], ['classroom', 'update_all_classroom_contacts']].each do |api_type, action|
  [['buildings', 'update_rooms']].each do |api_type, action|

    success, token_or_error = get_auth_token(api_type)
    unless success
      @debug = true
      errors << "No access_token. Error: #{token_or_error}"
      break
    end
    api = "#{api_type.capitalize}Api".constantize.new(token_or_error)
    task_time, @debug = update_api_data(api, action, action.humanize, task_time)
    break if @debug
    # sleep(61.seconds) if action != 'add_facility_id_to_classrooms'
  end

  if @debug
    errors << "Updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
  end

  status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
  message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + errors.join("\r\n")
  task_result.update_log(message, @debug)
end
