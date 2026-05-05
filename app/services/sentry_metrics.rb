class SentryMetrics
  class << self
    def count(name, value: 1, attributes: {})
      Sentry::Metrics.count(name, value: value, attributes: base_attributes.merge(attributes))
    rescue => error
      Rails.logger.debug("Sentry metric count failed for #{name}: #{error.class} #{error.message}")
    end

    def gauge(name, value, unit: nil, attributes: {})
      args = {attributes: base_attributes.merge(attributes)}
      args[:unit] = unit if unit.present?
      Sentry::Metrics.gauge(name, value.to_f, **args)
    rescue => error
      Rails.logger.debug("Sentry metric gauge failed for #{name}: #{error.class} #{error.message}")
    end

    def distribution(name, value, unit: nil, attributes: {})
      args = {attributes: base_attributes.merge(attributes)}
      args[:unit] = unit if unit.present?
      Sentry::Metrics.distribution(name, value.to_f, **args)
    rescue => error
      Rails.logger.debug("Sentry metric distribution failed for #{name}: #{error.class} #{error.message}")
    end

    private

    def base_attributes
      {
        app: "mi_classrooms",
        environment: Rails.env
      }
    end
  end
end
