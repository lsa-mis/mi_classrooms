# MClassrooms

![Ruby Version](https://img.shields.io/badge/Ruby%20Version-3.3.4-red) ![Rails Version](https://img.shields.io/badge/Rails%20Version-8.1-red)

## Authorization

- Devise: This application uses Devise for user authorization.
- omniauth-SAML
- ldap_lookup used to gather user information (especially group affiliation for authorization)

## Background Jobs

- SolidQueue (PostgreSQL-backed)

## Database

- PostgreSQL 12 (or higher)

### Database loading data

The application uses Buildings and Classrooms APIs from the UofM API directory: [api.umich.edu](https://api.umich.edu)
See the getting started instructions here: [api.umich.edu/start](https://api.umich.edu/start)

- Browse the UMAPI Directory
- Join a Developer Organization
- Register Your Application
- Subscribe to an API Plan
- Publish/Develop an API

To update the database locally, run:

```sh
bin/rails api_update_database
```

For a scheduled job on Hatchbox, run the task from the current release directory and set `RAILS_ENV` explicitly. Example for staging:

```sh
cd /home/deployer/apps/<app_name>/current && RAILS_ENV=staging bin/rails api_update_database >> /home/deployer/apps/<app_name>/shared/log/api_update_database_cron.log 2>&1
```

`bin/rails api_update_database` calls the following classes:

- `auth_token_api.rb`
- `buildings_api.rb`
- `classrooms_api.rb`
- `department_api.rb`

Note: you will initially run these rake tasks to add images to the application and the seed file to add initial data:

- `add_chairs_to_rooms.rake`
- `add_images_to_rooms.rake`
- `add_panos_to_rooms.rake`
- `rails db:seed`

Note: this task creates log files in `Rails.root/log/api_nightly_update_db.log` to store errors or warnings.

## Support / Questions

Please email the [LSA W&ADS Rails Team](mailto:lsa-was-rails-devs@umich.edu)
