# config/initializers/clear_dev_logs.rb

if Rails.env.devlopment?
  MAX_LOG_SIZE = 10.megabytes
  logs = File.join(Rails.root, "log", "*.log")
  if Dir[logs].any? { |log| File.size?(log).to_i > MAX_LOG_SIZE }
    $stdout.puts "Running rails log:clear"
    "rails log:clear"

  end
end
