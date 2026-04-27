module ApiUpdateDatabase
  class RunResult
    attr_reader :started_at, :finished_at, :phases

    def initialize(started_at:, finished_at:, phases:)
      @started_at = started_at
      @finished_at = finished_at
      @phases = phases
    end

    def success?
      phases.all?(&:success?)
    end

    def duration_seconds
      finished_at - started_at
    end

    def to_h
      {
        status: success? ? "success" : "error",
        started_at: started_at.iso8601,
        finished_at: finished_at.iso8601,
        duration_seconds: duration_seconds.round(2),
        phases: phases.map(&:to_h)
      }
    end
  end
end
