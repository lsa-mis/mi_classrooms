# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

desc "This will update buildings"
task update_buildings: :environment do

  auth_token = AuthTokenApi.new("bf", "buildings")
  result = auth_token.get_auth_token
  if result['success']
    access_token = result['access_token']
  else
    puts "No access_token. Error: " + result['error']
    exit
  end

  building = BuildingsApi.new(access_token)

  # result = building.get_building_data_by_id('1005046')
  # if result['success']
  #   building_data_by_id = result['data']
  #   puts building_data_by_id
  # else 
  #   puts result['error']
  #   exit
  # end

  # result = building.get_buildings_for_current_fiscal_year
  # if result['success']
  #   buildings_for_current_fiscal_year = result['data']
  #   puts buildings_for_current_fiscal_year
  #   puts buildings_for_current_fiscal_year['ListOfBldgs']['Buildings'].count
  # else 
  #   puts result['error']
  #   exit
  # end

  # result = building.get_building_classroom_data('1005046')
  # if result['success']
  #   building_classroom_data = result['data']
  #   puts building_classroom_data
  #   puts building_classroom_data.count
  # else 
  #   puts result['error']
  #   exit
  # end

  # result = building.get_building_classroom_data_for_fiscal_year('1005046', '2020')
  # if result['success']
  #   building_classroom_data_for_fiscal_year = result['data']
  #   puts building_classroom_data_for_fiscal_year
  #   puts building_classroom_data_for_fiscal_year.count
  # else 
  #   puts result['error']
  #   exit
  # end

end