# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

# The task will get info about all buildings (only for the Central Campus)
# and update buildings records or add new builodings if they are not in the database
# If a building is in the app db, but not in the API, a warning will be added to the log file

desc "This will update Ann Arbor campus buildings"
task update_buildings: :environment do

  auth_token = AuthTokenApi.new("bf", "buildings")
  result = auth_token.get_auth_token
  if result['success']
    access_token = result['access_token']
  else
    puts "No access_token. Error: " + result['error']
    exit
  end
  
  api = BuildingsApi.new(access_token)
  time = Benchmark.measure {
    result = api.update_all_buildings
  }
  puts "Update buildings Time: #{time.real.round(2)} seconds"
  puts "See the log file #{Rails.root}/log/#{Date.today}_building_api.log for errors or warnings"

end