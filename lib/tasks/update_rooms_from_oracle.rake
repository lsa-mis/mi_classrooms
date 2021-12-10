# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

# The task will get info about all rooms (only for the Central Campus)
# and update rooms records or add new rooms if they are not in the database
# If a room is in the app db, but not in the API, the room will be updated with: room.update(visible: false)

desc "This will update rooms for every building"
task update_rooms_from_oracle: :environment do

  # oci8_db = OCI8.new(#{Rails.application.credentials.oracle_db[:username]},#{Rails.application.credentials.oracle_db[:password]},#{Rails.application.credentials.oracle_db[:database]})
  
  campus_codes = ['100']
  buildings_codes = [1000440, 1000234, 1000204, 1000333, 1005224, 1005059, 1005347]

  begin
    oci8_db = OCI8.new("#{Rails.application.credentials.oracle_db[:username]}", "#{Rails.application.credentials.oracle_db[:password]}", "#{Rails.application.credentials.oracle_db[:database]}")
    oracle_database = OracleDatabase.new(oci8_db)
    time = Benchmark.measure {
      puts "running ..."

      time = Benchmark.measure {
        auth_token = AuthTokenApi.new("bf", "buildings")
        result = auth_token.get_auth_token
        if result['success']
          access_token = result['access_token']
        else
          puts "No access_token. Error: " + result['error']
          exit
        end
        api = BuildingsApi.new(access_token)
        api.update_campus_list
      }
      puts "Update campus list Time: #{time.real.round(2)} seconds"
      puts "See the log file #{Rails.root}/log/#{Date.today}_campus_api.log for errors or warnings"

      time = Benchmark.measure {
        oracle_database.update_all_buildings(campus_codes, buildings_codes)
      }
      puts "Update Buildings Time: #{time.real.round(2)} seconds"
      puts "See the log file #{Rails.root}/log/#{Date.today}_room_update.log for errors or warnings"

      time = Benchmark.measure {
        oracle_database.update_rooms
      }
      puts "Update Rooms Time: #{time.real.round(2)} seconds"
      puts "See the log file #{Rails.root}/log/#{Date.today}_room_update.log for errors or warnings"

      time = Benchmark.measure {
        oracle_database.update_classroom_characteristics
      }
      puts "Update Classroom Characteristics Time: #{time.real.round(2)} seconds"
      puts "See the log file #{Rails.root}/log/#{Date.today}_classroom_characteristics_update.log for errors or warnings"

      UpdateRoomCharacteristicsArrayJob.perform_now

      time = Benchmark.measure {
        oracle_database.update_classroom_contacts
      }
      puts "Update Classroom Contacts Time: #{time.real.round(2)} seconds"
      puts "See the log file #{Rails.root}/log/#{Date.today}_classroom_contacts_update.log for errors or warnings"
    }
    puts "Update Classroom Database Total Time: #{time.real.round(2)} seconds"
    oci8_db.logoff
    puts "Oracle logoff"
  rescue OCIError
    # display the error message
    puts "OCIError occured!"
    puts "Code: " + $!.code.to_s
    puts "Desc: " + $!.message
    subject = "#{Date.today} - update_rooms_from_oracle failed"
    message = "OCIError occured!\r\nCode: " + $!.code.to_s + "\r\nDesc: " + $!.message
    ActionMailer::Base.mail(
      from: "mi_classrooms@example.com",
      to: "brita@umich.edu",
      subject: subject,
      body: message
    ).deliver
  end

end
