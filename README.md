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
  ## Ruby 2.7.2
  ## Rails 6.1 (edge)

* System dependencies

    ## Authorization
     - Devise:  This application uses Devise for user authorization.
     - omniauth-google-oauth2 (OAth configured for local domain)
     - ldap_lookup used to gather user information (especially group affiliation)

    ## Background Jobs
      Sidekiq 6.x
      Redis 6.x


* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
