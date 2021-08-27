# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

  ** Working Files Directory

  Each product gets a working_files directory that is ignored by git and not part of the deployed application. The purpose of this directory is a place to keep 'work artifacts' that aren't intended for the final product. Examples include

  1. Notes
  2. temporary 'experiments' (copies of different versions of a logo for example)
  3. Site diagrams



* Ruby version
  ## Ruby 3.0.1
  ## Rails 6.1 (edge)

* System dependencies

    ## Authorization
     - Devise:  This application uses Devise for user authorization.
     - omniauth-google-oauth2 (OAth configured for local domain)
     - ldap_lookup used to gather user information (especially group affiliation)

    ## Background Jobs
      Sidekiq 6.x
      Redis 6.x

    ## Database
      Postgresql 13.2 (or higher)

* Configuration

* Database creation
```
bundle exec rails db:create
bundle exec rails db:migrate
```

* Database loading data

Data is loaded using a series of rake tasks that import data from .csv files. The import tasks assume the files are located in a directory at the root of the application named 'uploads'. 

The import commands are listed below.
```
bundle exec rails import:buildings
bundle exec rails import:rooms
bundle exec rails import:room_contacts
bundle exec rails import:room_characteristics
```
** NOTE: The buildings importer needs to be run first, followed by rooms. Rooms depend on buildings and both room_contacts and room_characteristics depend on rooms. 

** NOTE: The buildings importer initiates a GeocodeBuildingJob for each building created. This job does a geolocation lookup to determine the building's latitude and longitude based on it's street address.

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
