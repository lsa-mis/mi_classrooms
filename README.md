# MClassrooms

![Ruby Version](https://img.shields.io/badge/Ruby%20Version-3.3.4-red) ![Rails Version](https://img.shields.io/badge/Rails%20Version-8.1-red)

## Authorization

- Devise: This application uses Devise for user authorization.
- omniauth-SAML
- ldap_lookup used to gather user information (especially group affiliation for authorization)

### Non-production test login

When SAML/IdP callback targets are controlled externally (for example, University auth callbacks pointing to another server), you can enable a temporary test login in non-production environments:

```sh
ENABLE_TEST_LOGIN=true \
TEST_LOGIN_TOKEN=<choose-a-secret-token> \
TEST_LOGIN_EMAIL=<your-umich-email> \
bin/rails server
```

Then visit:

```text
/test_login?token=<choose-a-secret-token>
```

Optional:

- `TEST_LOGIN_GROUPS=mi-classrooms-admin-staging,mi-classrooms-non-admin-staging` to control role/group behavior.
- If `TEST_LOGIN_GROUPS` is omitted, the login defaults to admin for the current non-production environment.

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
