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

* Database loading data via API

The application uses Buildings ans Classroms APIs from the UofM API directory https://api.umich.edu. 
Check _Getting started_ instruction here https://api.umich.edu/start to

- Browse the API Directory
- Join a Developer Organization
- Register Your Application
- Subscribe to an API Plan
- Publish/Develop an API

To update the database the following tasks must be run in the following order, the next task afer the previous is finished:

- bin/rake update_campus_list
- bin/rake update_buildings
- bin/rake update_rooms
- bin/rake add_facility_id_to_classrooms
- bin/rake update_classroom_characteristics
- bin/rake update_classroom_characteristics_array
- bin/rake update_classroom_contacts


* Tasks descriptions

update_campus_list
```
From the Buildings API get a list of Campuses and update campus_records table in the database
```
update_buildings
```
From the Buildings API get a list of buildings (for campuses IDs that are passed to the task as an argument),
update buildings in the database if they exist or add new buildings if they don't exist.
The task initiates a GeocodeBuildingJob for each building created. 
This job does a geolocation lookup to determine the building's latitude and longitude based on it's street address.
```
update_rooms
```
From the Buildings API for every building in the database get a list of rooms,
update rooms records or add new rooms if they don't exist in the database.
If a room is in the application database, but not in the API returned list, 
the room will be updated with: room.update(visible: false)
```
add_facility_id_to_classrooms
```
From the Classrooms API get a list of classrooms (for campuses IDs that are passed to the task as an argument), 
and add FacilityID to every classroom in the database.
The FacilityID is needed to get information about classroom_characteristics and classroom_contacts in next tasks
```
update_classroom_characteristics
```
From the Classrooms API for every classroom in the database get classroom characteristics, 
delete all classroom_characteristics for that classroom and create a new classroom_characteristics records
```
update_classroom_characteristics_array
```
For every classroom create an array from this classroom's classroom_characteristics records 
and update characteristics field for this classroom.
The task runs UpdateRoomCharacteristicsArrayJob
```
update_classroom_contacts
```
From the Classrooms API for every classroom in the database get classroom contacts, 
update the room_contacts table or add a new contact record if it dosn't exist.
```


** NOTE: The tasks create log files in {Rails.root}/log/#{Date.today}_<task_name>.log to store errors of warnings.

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
