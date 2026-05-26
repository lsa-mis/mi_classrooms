# MClassrooms

![Ruby Version](https://img.shields.io/badge/Ruby%20Version-3.4.7-red) ![Rails Version](https://img.shields.io/badge/Rails%20Version-8.1-red)

## Authorization

- Devise: This application uses Devise for user authorization.
- omniauth-SAML
- ldap_lookup used to gather user information (especially group affiliation for authorization)

### Non-production test login (not available in production)

When SAML/IdP callback targets are controlled externally (for example, University auth callbacks pointing to another server), you can enable a **secret URL** on **development, test, or staging** only. The `/test_login` route is not registered when `Rails.env.production?` is true, and the controller rejects those requests, so a true production deploy never exposes this feature. (Use a dedicated environment such as `staging` for Siteimprove; a server that runs `RAILS_ENV=production` against a staging hostname is still treated as production.)

Use a long random `TEST_LOGIN_TOKEN`, store it in a vault, rotate if it leaks, and set `ENABLE_TEST_LOGIN` only when needed.

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
- If `TEST_LOGIN_GROUPS` is omitted, the login defaults to admin for the current non-production environment (`mi-classrooms-admin-staging` in staging).

#### Siteimprove on staging

[Siteimprove](https://help.siteimprove.com/support/solutions/articles/80001162737-the-siteimprove-crawler-bot-information) cannot complete your interactive SSO. Point the crawl at **staging** only: set `ENABLE_TEST_LOGIN` and related variables on the **staging** host, then use a **start URL** such as `https://<staging-host>/test_login?token=<your-secret-token>` so the crawler receives session and remember-me cookies after the redirect. Crawler identity and IPs: [What IP addresses and user agents are used by Siteimprove?](https://help.siteimprove.com/support/solutions/articles/80000448553-what-ip-addresses-and-user-agents-are-used-by-siteimprove-). Ensure `robots.txt` does not disallow paths you need crawled; you can allow `SiteimproveBot-Crawler` if you add restrictive rules for other bots.

## Configuration (production / staging)

Optional environment variables:

- **Mail**: `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USER_NAME`, `SMTP_PASSWORD`, `SMTP_AUTHENTICATION` (default `login`), `SMTP_ENABLE_STARTTLS_AUTO` (default `true`), `MAILER_FROM`
- **Active Storage**: `ACTIVE_STORAGE_SERVICE` (default `local`; set to `amazon` when S3 is configured) and `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET`
- **Mission Control / Solid Queue dashboard**: comma-separated `MISSION_CONTROL_ALLOWED_EMAILS` (defaults to the previous single-operator allowlist if unset)

## Background Jobs

- SolidQueue (PostgreSQL-backed)

## Database

- PostgreSQL 12 (or higher)

### U-M API HTTPS

`lib/um_api.rb` uses normal TLS verification (`VERIFY_PEER`, minimum TLS 1.2). If token or API calls fail in an environment with a custom CA bundle, set `SSL_CERT_FILE` (or your platform's equivalent) so OpenSSL can validate `gw.api.it.umich.edu`.

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
