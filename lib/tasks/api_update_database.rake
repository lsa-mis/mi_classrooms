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
  result = auth_token.get_auth_token
  if result['success']
    access_token = result['access_token']
    total_time = 0
    api = BuildingsApi.new(access_token)
  else
    @debug = true
    log.api_logger.debug "get access token for update_campus_list, error: No access_token - #{result['error']}"
    errors << "No access_token. Error: " + result['error']
    status_report << "Total time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update Campuses errors:\r\n" + errors.join("\r\n")
    task_result.update_log(message, @debug)
    exit
  end
  
  time = Benchmark.measure {
    @debug = api.update_campus_list
  }
  puts "Update campus list Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Update campus list Time: #{time.real.round(2)} seconds"
  if @debug
    status_report << "Campus updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "

  #################################################
  # update buildings
  # if building is in the app db, but not in the API, a warning will be added to the log file
  # 
  total_time += time.real.to_i
  # check auth_token expiration time
  if total_time > 3600
    auth_token = AuthTokenApi.new("buildings")
    result = auth_token.get_auth_token
    if result['success']
      total_time = 0
      access_token = result['access_token']
      api = BuildingsApi.new(access_token)
    else
      @debug = true
      log.api_logger.debug "get access token for update_all_buildings, error: No access_token - #{result['error']}"
      errors << "No access_token. Error: " + result['error']
      status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
      message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update buildings errors:\r\n" + errors.join("\r\n")
      task_result.update_log(message, @debug)
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
    status_report << "Buildings updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "
  sleep(61.seconds)

  #################################################
  # update rooms
  # 
  total_time += time.real.to_i
  if total_time > 3600
    auth_token = AuthTokenApi.new("buildings")
    result = auth_token.get_auth_token
    if result['success']
      puts "token success"
      total_time = 0
      access_token = result['access_token']
      api = BuildingsApi.new(access_token)
    else
      @debug = true
      log.api_logger.debug "get access token for update_rooms, error: No access_token - #{result['error']}"
      errors << "No access_token. Error: " + result['error']
      status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
      message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update rooms errors:\r\n" + errors.join("\r\n")
      task_result.update_log(message, @debug)
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
    status_report << "Rooms updates failed. See the log file #{Rails.root}/log/#{Date.today}_room_api.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "
  
  ################################################
  # add facility_id to classrooms and update instructional_seating_count
  # 
  auth_token = AuthTokenApi.new("classrooms")
  result = auth_token.get_auth_token
  if result['success']
    total_time = 0
    access_token = result['access_token']
    api = ClassroomApi.new(access_token)
  else
    @debug = true
    log.api_logger.debug "get access token for add_facility_id_to_classrooms, error: No access_token - #{result['error']}"
    errors << "No access_token. Error: " + result['error']
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Add facility_id to Classrooms errors:\r\n" + errors.join("\r\n")
    task_result.update_log(message, @debug)
    exit
  end

  time = Benchmark.measure {
    @debug = api.add_facility_id_to_classrooms
  }
  puts "Add FacilityID to Classrooms Time: #{time.real.round(2)} seconds"
  task_time += (time.real / 60) % 60
  status_report << "Add FacilityID for classroom Time: #{time.real.round(2)} seconds"
  if @debug
    status_report << "Add FacilityID to Classroom updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "
  sleep(61.seconds)

  #################################################
  # update classrooms characteristics
  # 
  total_time += time.real.to_i
  if total_time > 3600
    auth_token = AuthTokenApi.new("classrooms")
    result = auth_token.get_auth_token
    if result['success']
      total_time = 0
      access_token = result['access_token']
      api = ClassroomApi.new(access_token)
    else
      @debug = true
      log.api_logger.debug "get access token for update_all_classroom_characteristics, error: No access_token - #{result['error']}"
      errors << "No access_token. Error: " + result['error']
      status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
      message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update Classroom Characteristics errors:\r\n" + errors.join("\r\n")
      task_result.update_log(message, @debug)
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
    status_report << "Classroom Characteristics updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "
  sleep(61.seconds)
  
  #################################################
  # update classrooms contacts
  # 
  total_time += time.real.to_i
  if total_time > 3600
    auth_token = AuthTokenApi.new("classrooms")
    result = auth_token.get_auth_token
    if result['success']
      total_time = 0
      access_token = result['access_token']
      api = ClassroomApi.new(access_token)
    else
      @debug = true
      log.api_logger.debug "get access token for update_all_classroom_contacts, error: No access_token - #{result['error']}"
      errors << "No access_token. Error: " + result['error']
      status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
      message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n" + "Update classrooms contacts errors:\r\n" + errors.join("\r\n")
      task_result.update_log(message, @debug)
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
    status_report << "Classroom Contacts updates failed. See the log file #{Rails.root}/log/api_nightly_update_db.log for errors"
    status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
    message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
    task_result.update_log(message, @debug)
    exit
  end
  status_report << " "

  status_report << "\r\n\r\nTotal time: #{task_time.round(2)} minutes"
  message = "Time report:\r\n" + status_report.join("\r\n") + "\r\n\r\n"
  task_result.update_log(message, @debug)
  
end
