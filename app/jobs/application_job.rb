class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  around_perform do |job, block|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    attrs = metric_attributes(job)
    SentryMetrics.count("jobs.started", value: 1, attributes: attrs)

    begin
      block.call
      SentryMetrics.count("jobs.succeeded", value: 1, attributes: attrs)
    rescue StandardError => error
      SentryMetrics.count("jobs.failed", value: 1, attributes: attrs.merge(error_class: error.class.name))
      raise
    ensure
      elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000
      SentryMetrics.distribution("jobs.duration", elapsed_ms, unit: "millisecond", attributes: attrs)
    end
  end

  private

  def metric_attributes(job)
    {
      job_class: job.class.name,
      queue: job.queue_name,
      adapter: ActiveJob::Base.queue_adapter.class.name
    }
  end
end
