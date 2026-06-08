# frozen_string_literal: true

Sentry.init do |config|
  revision_file = Rails.root.join("REVISION")

  # Prefer ENV for deployment overrides, then fallback to credentials.
  config.dsn = ENV["SENTRY_DSN"].presence || Rails.application.credentials.dig(:sentry, :dsn)
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", Rails.env)
  config.release =
    ENV["SENTRY_RELEASE"].presence ||
    ENV["SOURCE_VERSION"].presence ||
    (File.read(revision_file).strip if File.exist?(revision_file))

  # Only enable in production and staging environments
  config.enabled_environments = %w[production staging]

  # Logging configuration
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Keep PII disabled by default; opt-in per environment with SENTRY_SEND_DEFAULT_PII=true
  config.send_default_pii = ENV["SENTRY_SEND_DEFAULT_PII"] == "true"

  # For shorter-lived worker processes, fewer background threads reduce drop risk on shutdown.
  config.background_worker_threads = Rails.env.production? ? 3 : 0

  # Profile sampling is relative to traced requests.
  # In production this results in ~2% profiled requests (0.2 * 0.1).
  config.profiles_sample_rate = 0.0

  config.traces_sampler = lambda do |context|
    transaction_name = context.dig(:transaction_context, :name).to_s

    if transaction_name.include?("health_check") || transaction_name.include?("/up")
      0.0
    elsif Rails.env.production?
      0.03
    else
      0.0
    end
  end
  # Ignore noisy errors that are not actionable in app code.
  config.excluded_exceptions += [
    "ActionController::RoutingError",
    "ActiveRecord::RecordNotFound"
  ]

  # Add additional context to errors
  config.before_send = lambda do |event, _hint|
    # Attach actor context when available.
    if defined?(Current) && Current.user
      event.user = {
        id: Current.user.id,
        email: Current.user.email
      }
    end

    # Drop healthcheck noise if it reaches error reporting.
    transaction = event.respond_to?(:transaction) ? event.transaction.to_s : ""
    if transaction.include?("health_check") || transaction.include?("/up")
      nil
    else
      event
    end
  end

  # Configure backtrace cleanup
  config.backtrace_cleanup_callback = lambda do |backtrace|
    Rails.backtrace_cleaner.clean(backtrace)
  end
end
