# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

desc "This will update classroom"
task update_classroom: :environment do

  auth_token = AuthTokenApi.new("aa", "classrooms")
  result = auth_token.get_auth_token
  if result['success']
    access_token = result['access_token']
  else
    puts "No access_token. Error: " + result['error']
    exit
  end

  classroom = ClassroomApi.new('USB1230', access_token)

  # classroom_info  = classroom.get_classroom_info
  # puts classroom_info

  # classroom_characteristics = classroom.get_classroom_characteristics
  # puts classroom_characteristics

  # classroom_contact  = classroom.get_classroom_contact
  # puts classroom_contact

  classroom_meetings  = classroom.get_classroom_meetings("09/01/2021", "10/20/2021")
  puts classroom_meetings

end