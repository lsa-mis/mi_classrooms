#!/usr/bin/env puma

directory "/home/deployer/apps/mi_classrooms/current"
rackup "/home/deployer/apps/mi_classrooms/current/config.ru"
environment "production"

pidfile "/home/deployer/apps/mi_classrooms/shared/tmp/pids/puma.pid"
state_path "/home/deployer/apps/mi_classrooms/shared/tmp/pids/puma.state"
stdout_redirect "/home/deployer/apps/mi_classrooms/current/log/puma.error.log", "/home/deployer/apps/mi_classrooms/current/log/puma.access.log", true

threads 4, 16

bind "unix:///home/deployer/apps/mi_classrooms/shared/tmp/sockets/mi_classrooms-puma.sock"

workers 2

preload_app!
on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = "/home/deployer/apps/mi_classrooms/current/Gemfile"
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
