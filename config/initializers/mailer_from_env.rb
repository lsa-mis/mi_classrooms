# frozen_string_literal: true

# Mail delivery for production and staging: set SMTP_ADDRESS (and related ENV vars)
# to use SMTP; otherwise Action Mailer falls back to :sendmail (see environment files).
if Rails.env.in?(%w[production staging])
  Rails.application.config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_FROM", "mi.classrooms.feedback@umich.edu")
  }

  if ENV["SMTP_ADDRESS"].present?
    Rails.application.config.action_mailer.delivery_method = :smtp
    Rails.application.config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: ENV.fetch("SMTP_PORT", "587").to_i,
      domain: ENV.fetch("SMTP_DOMAIN", "localhost"),
      user_name: ENV["SMTP_USER_NAME"].presence,
      password: ENV["SMTP_PASSWORD"].presence,
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "login").to_sym,
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(
        ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true")
      )
    }.compact
  end
end
