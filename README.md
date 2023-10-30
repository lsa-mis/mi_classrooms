# MClassrooms

![](https://img.shields.io/badge/Ruby%20Version-3.0.1-red) ![](https://img.shields.io/badge/Rails%20Version-6.1.5-red)

  ## Authorization
  - Devise:  This application uses Devise for user authorization.
  - omniauth-SAML
  - ldap_lookup used to gather user information (especially group affiliation for authorization)

  ## Background Jobs
  - Sidekiq 6.4.x
  - Redis 4.x

  ## Database
  - Postgresql 12 (or higher)
  ### Database loading data


   - The application uses Buildings and Classrooms APIs from the UofM API directory https://api.umich.edu. 
Check _Getting started_ instruction here https://api.umich.edu/start

      - Browse the UMAPI Directory
      - Join a Developer Organization
      - Register Your Application
      - Subscribe to an API Plan
      - Publish/Develop an API

   - To update the database run bin/rake api_update_database

   - bin/rake api_update_database _calls the following classes_
     - auth_token_api.rb
     - buildings_api.rb
     - classrooms_api.rb
     - department_api.rb
  - Note: you will initially run these rake tasks to add images to the application and the seed file to add intial data
    - add_chairs_to_rooms.rake
    - add_images_to_rooms.rake
    - add_panos_to_rooms.rake
    - rails db:seed

** NOTE: The task create log files in {Rails.root}/log/api_nightly_update_db.log to store errors of warnings.

*** test

# Support / Questions
  Please email the [LSA W&ADS Rails Team](mailto:lsa-was-rails-devs@umich.edu)
