require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MiClassrooms
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.generators do |g|
      g.test_framework false
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.channel assets: false
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators.system_tests = nil
    config.active_job.queue_adapter = :sidekiq
    config.active_record.schema_format = :sql
  end
  ActiveStorage::Engine.config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")

  ActiveStorage::Engine.config.active_storage.content_types_allowed_inline.append("image/svg+xml")
  Webpacker::Compiler.env["TAILWIND_MODE"] = "build"
end
