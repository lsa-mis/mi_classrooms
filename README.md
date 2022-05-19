# MClassrooms

![](https://img.shields.io/badge/Ruby%20Version-3.0.1-red) ![](https://img.shields.io/badge/Rails%20Version-6.1.0-red)

  ## Authorization
  - Devise:  This application uses Devise for user authorization.
  - omniauth-SAML
  - ldap_lookup used to gather user information (especially group affiliation for authorization)

  ## Background Jobs
  - Sidekiq 6.x
  - Redis 6.x

  ## Database
  - Postgresql 12 (or higher)
  ### Database loading data


   - The application uses Buildings ans Classroms APIs from the UofM API directory https://api.umich.edu. 
Check _Getting started_ instruction here https://api.umich.edu/start

      - Browse the UMAPI Directory
      - Join a Developer Organization
      - Register Your Application
      - Subscribe to an API Plan
      - Publish/Develop an API

      To update the database the following tasks must be run in the following order, the next task afer the previous is finished:

  - bin/rake api_update_database _which calls the following classes_
    - auth_token_api.rb
    - buildings_api.rb
    - classrooms_api.rb
    - department_api.rb
    - Note: you will initially run the rake tasks to add images to the application
        - add_chairs_to_rooms.rake
        - add_images_to_rooms.rake
        - add_panos_to_rooms.rake

** NOTE: The task create log files in {Rails.root}/log/#{Date.today}_<task_name>.log to store errors of warnings.
