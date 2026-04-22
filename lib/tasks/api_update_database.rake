# Add crontask to server in order to run this at a specified time
require "benchmark"
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

# update campus_records table in the database
# If campus is in the app db, but not in the API, a warning will be added to the log file

desc "This will update Classrooms database using APIs"
task api_update_database: :environment do
  Rails.logger.info({event: "api_update_database.start", environment: Rails.env}.to_json)
  log = ApiLog.new
  errors = []
  status_report = []
  task_time = 0
  # @debug is true if there are errors from API calls or database queries
  @debug = false
  task_result = TaskResultLog.new

  write_result = lambda do |extra_message = nil|
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    message += extra_message if extra_message.present?
    task_result.update_log(message, @debug)
  end

  ensure_token = lambda do |scope, action_name, error_heading|
    result = AuthTokenApi.new(scope).get_auth_token
    return true if result["success"]

    @debug = true
    log.api_logger.debug "get access token for #{action_name}, error: No access_token - #{result["error"]}"
    errors << "No access_token. Error: #{result["error"]}"
    write_result.call("#{error_heading} errors:\r\n" + errors.join("\r\n"))
    false
  end

  run_phase = lambda do |time_label:, failure_label:, log_file:, api:, method_name:, after_success: nil|
    time = Benchmark.measure do
      @debug = api.public_send(method_name)
      after_success.call unless @debug || after_success.nil?
    end

    seconds = time.real.round(2)
    puts "#{time_label} Time: #{seconds} seconds"
    Rails.logger.info({event: "api_update_database.phase", phase: time_label, seconds: seconds, success: !@debug}.to_json)
    task_time += (time.real / 60) % 60
    status_report << "#{time_label} Time: #{seconds} seconds"
    if @debug
      status_report << "#{failure_label} See the log file #{log_file} for errors"
      write_result.call
      false
    else
      status_report << " "
      true
    end
  end

  #################################################
  # update campus list
  # if campus is in the app db, but not in the API, a warning will be added to the log file
  unless ensure_token.call("buildings", "update_campus_list", "Update Campuses")
    exit
  end

  buildings_api = BuildingsApi.new
  exit unless run_phase.call(
    time_label: "Update campus list",
    failure_label: "Campus updates failed.",
    log_file: "#{Rails.root}/log/api_nightly_update_db.log",
    api: buildings_api,
    method_name: :update_campus_list
  )

  #################################################
  # update buildings
  # if building is in the app db, but not in the API, a warning will be added to the log file
  exit unless run_phase.call(
    time_label: "Update buildings",
    failure_label: "Buildings updates failed.",
    log_file: "#{Rails.root}/log/api_nightly_update_db.log",
    api: buildings_api,
    method_name: :update_all_buildings
  )
  sleep(61.seconds)

  #################################################
  # update rooms
  exit unless run_phase.call(
    time_label: "Update Rooms",
    failure_label: "Rooms updates failed.",
    log_file: "#{Rails.root}/log/#{Date.today}_room_api.log",
    api: buildings_api,
    method_name: :update_rooms
  )

  ################################################
  # add facility_id to classrooms and update instructional_seating_count
  unless ensure_token.call("classrooms", "add_facility_id_to_classrooms", "Add facility_id to Classrooms")
    exit
  end

  classroom_api = ClassroomApi.new
  exit unless run_phase.call(
    time_label: "Add FacilityID to Classrooms",
    failure_label: "Add FacilityID to Classroom updates failed.",
    log_file: "#{Rails.root}/log/api_nightly_update_db.log",
    api: classroom_api,
    method_name: :add_facility_id_to_classrooms
  )
  sleep(61.seconds)

  #################################################
  # update classrooms characteristics
  exit unless run_phase.call(
    time_label: "Update classroom characteristics",
    failure_label: "Classroom Characteristics updates failed.",
    log_file: "#{Rails.root}/log/api_nightly_update_db.log",
    api: classroom_api,
    method_name: :update_all_classroom_characteristics,
    after_success: -> { UpdateRoomCharacteristicsArrayJob.perform_now }
  )
  sleep(61.seconds)

  #################################################
  # update classrooms contacts
  exit unless run_phase.call(
    time_label: "Update classroom contacts",
    failure_label: "Classroom Contacts updates failed.",
    log_file: "#{Rails.root}/log/api_nightly_update_db.log",
    api: classroom_api,
    method_name: :update_all_classroom_contacts
  )

  write_result.call
  Rails.logger.info({event: "api_update_database.complete", total_minutes: task_time.round(2)}.to_json)
end
