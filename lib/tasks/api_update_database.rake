# Add crontask to server in order to run this at a specified time
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
  TOKEN_EXPIRATION_TIME = 3600
  log = ApiLog.new
  errors = []
  status_report = []
  task_time = 0
  # @debug is true if there are errors from API calls or database queries
  @debug = false
  task_result = TaskResultLog.new
  
  #################################################
  # update campus list
  # if campus is in the app db, but not in the API, a warning will be added to the log file
  # 
  auth_token = AuthTokenApi.new("buildings")
  # auth_token "expires_in":3600 seconds
  access_token = auth_token.get_auth_token
  if access_token
    total_time = 0
    api = BuildingsApi.new(access_token)
  else
    log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update campuses errors: No access_token."
    exit
  end
  
  time = Benchmark.measure {
    @debug = api.update_campus_list
  }
  puts "Update campus list Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update campus list Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Update campuses", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "

  #################################################
  # update buildings
  # if building is in the app db, but not in the API, a warning will be added to the log file
  # 
  total_time += time.real.to_i
  # check auth_token expiration time
  if total_time > TOKEN_EXPIRATION_TIME
    auth_token = AuthTokenApi.new("buildings")
    access_token = auth_token.get_auth_token
    if access_token
      total_time = 0
      api = BuildingsApi.new(access_token)
    else
      log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update Buildings errors: No access_token."
      exit
    end
  end
  
  api = BuildingsApi.new(access_token)
  time = Benchmark.measure {
    @debug = api.update_all_buildings
  }

  puts "Update buildings Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update buildings Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Update buildings", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "
  sleep(61.seconds)

  #################################################
  # update rooms
  # 
  total_time += time.real.to_i
  if total_time > TOKEN_EXPIRATION_TIME
    auth_token = AuthTokenApi.new("buildings")
    access_token = auth_token.get_auth_token
    if access_token
      total_time = 0
      api = BuildingsApi.new(access_token)
    else
      log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update Rooms errors: No access_token."
      exit
    end
  end

  time = Benchmark.measure {
    # puts "lets update rooms"
    @debug = api.update_rooms
  }
  puts "Update Rooms Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update Rooms Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Update rooms", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "
  
  ################################################
  # add facility_id to classrooms and update instructional_seating_count
  # 
  auth_token = AuthTokenApi.new("classrooms")
  access_token = auth_token.get_auth_token
  if access_token
    total_time = 0
    api = ClassroomApi.new(access_token)
  else
    @debug = true
    log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "add facility_id to classrooms errors: No access_token."
    exit
  end

  time = Benchmark.measure {
    @debug = api.add_facility_id_to_classrooms
  }
  puts "Add FacilityID to Classrooms Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Add FacilityID for classroom Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Add FacilityID to classrooms", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "
  sleep(61.seconds)

  #################################################
  # update classrooms characteristics
  # 
  total_time += time.real.to_i
  if total_time > TOKEN_EXPIRATION_TIME
    auth_token = AuthTokenApi.new("classrooms")
    access_token = auth_token.get_auth_token
    if access_token
      total_time = 0
      api = BuildingsApi.new(access_token)
    else
      log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update Classroom Characteristics errors: No access_token."
      exit
    end
  end

  time = Benchmark.measure {
    @debug = api.update_all_classroom_characteristics
    UpdateRoomCharacteristicsArrayJob.perform_now unless @debug
  }
  puts "Update classroom characteristics Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update classroom characteristics Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Update classroom characteristics", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "
  sleep(61.seconds)
  
  #################################################
  # update classrooms contacts
  # 
  total_time += time.real.to_i
  if total_time > TOKEN_EXPIRATION_TIME
    auth_token = AuthTokenApi.new("classrooms")
    access_token = auth_token.get_auth_token
    if access_token
      total_time = 0
      api = BuildingsApi.new(access_token)
    else
      log.api_logger.debug "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update classrooms contacts errors: No access_token."
      exit
    end
  end

  time = Benchmark.measure {
    @debug = api.update_all_classroom_contacts
  }
  puts "Update classroom contacts Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update classroom contacts Time: #{time.real.round(2)} seconds"
  if @debug
    task_result.update_log_table_with_errors(task: "Update classroom contacts", task_time: task_time, status_report: status_report)
    exit
  end
  status_report << " "

  status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
  message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
  task_result.update_log_table(message: message, debug: @debug)
  
end
