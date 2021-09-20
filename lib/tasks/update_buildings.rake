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
  @access_token = auth_token.get_auth_token

  building = BuildingsApi.new('1005046', @access_token)
  # building_data = building.get_building_data
  # buildings_for_current_fiscal_year = building.get_buildings_for_current_fiscal_year

  # building_room_data = building.get_building_room_data
  building_room_data_for_fiscal_year = building.get_building_room_data_for_fiscal_year

end