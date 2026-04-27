module ApiUpdateDatabase
  class PhaseResult
    COUNTERS = %i[
      api_calls
      created
      updated
      deleted
      deactivated
      skipped
      retries
      rate_limit_sleeps
      would_delete
    ].freeze

    attr_reader :phase, :started_at, :finished_at, :warnings, :errors, :metadata

    def initialize(phase)
      @phase = phase
      @started_at = Time.current
      @finished_at = nil
      @warnings = []
      @errors = []
      @metadata = {}
      @counters = COUNTERS.index_with { 0 }
    end

    def increment(counter, by = 1)
      @counters[counter.to_sym] = @counters.fetch(counter.to_sym, 0) + by.to_i
    end

    def add_warning(message)
      @warnings << message
    end

    def add_error(message)
      @errors << message
    end

    def add_metadata(key, value)
      @metadata[key.to_sym] = value
    end

    def finish
      @finished_at ||= Time.current
      self
    end

    def success?
      errors.empty?
    end

    def duration_seconds
      return nil unless finished_at

      finished_at - started_at
    end

    def counters
      @counters.dup
    end

    def to_h
      {
        phase: phase,
        status: success? ? "success" : "error",
        started_at: started_at&.iso8601,
        finished_at: finished_at&.iso8601,
        duration_seconds: duration_seconds&.round(2),
        counters: counters,
        warnings: warnings,
        errors: errors,
        metadata: metadata
      }
    end
  end
end
