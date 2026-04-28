# Add crontask to server in order to run this at a specified time
#   run crontab -e
#================================
#   49 3 * * * /bin/bash -l -c 'cd /home/deployer/apps/vodsecurityproduction/current && RAILS_ENV=production /home/deployer/.rbenv/shims/bundle exec rake devicinator >> /home/deployer/apps/vodsecurityproduction/shared/log/cronstuff.log 2>&1'
#================================

# https://en.wikipedia.org/wiki/Cron
# https://medium.com/@pawlkris/scheduling-tasks-in-rails-with-cron-and-using-the-whenever-gem-34aa68b992e3

# update campus_records table in the database
# If campus is in the app db, but not in the API, a warning will be added to the log file

desc "This will update Classrooms database using APIs"
task api_update_database: :environment do
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  task_attrs = {task: "api_update_database"}
  SentryMetrics.count("rake.started", value: 1, attributes: task_attrs)

  result = ApiUpdateDatabase::Runner.new(
    delete_dry_run: ActiveModel::Type::Boolean.new.cast(ENV["API_UPDATE_DELETE_DRY_RUN"])
  ).run

  if result.success?
    SentryMetrics.count("rake.succeeded", value: 1, attributes: task_attrs)
  else
    SentryMetrics.count("rake.failed", value: 1, attributes: task_attrs.merge(failure_type: "unsuccessful_result"))
  end

  exit(result.success?)
rescue StandardError => error
  SentryMetrics.count("rake.failed", value: 1, attributes: task_attrs.merge(error_class: error.class.name))
  raise
ensure
  if defined?(started_at) && started_at
    elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000
    SentryMetrics.distribution("rake.duration", elapsed_ms, unit: "millisecond", attributes: task_attrs || {task: "api_update_database"})
  end
end
