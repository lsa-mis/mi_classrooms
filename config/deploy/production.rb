server "mi_classrooms.com", user: "deployer", roles: %w[app db web]
set :stage, :production
set :branch, :master
set :deploy_user, "deployer"
set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/mi_classrooms"
set :branch, "master"
set :rails_env, "production"
set :puma_env, "production"
set :puma_conf, "#{shared_path}/config/puma.rb"