class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  around_perform do |job, block|
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    attrs = metric_attributes(job)
    SentryMetrics.count("jobs.started", value: 1, attributes: attrs)

    Sentry.with_scope do |scope|
      scope.set_tags(
        job_class: job.class.name,
        job_queue: job.queue_name,
        queue_adapter: ActiveJob::Base.queue_adapter.class.name
      )
      extras = {
        job_id: job.job_id,
        executions: job.executions,
        priority: job.priority
      }
      if sentry_job_arg_types_enabled?
        extras[:argument_types] = safe_argument_types(job.arguments)
        extras[:argument_count] = job.arguments.size
      end
      scope.set_extras(extras)

      begin
        block.call
        SentryMetrics.count("jobs.succeeded", value: 1, attributes: attrs)
      rescue => error
        SentryMetrics.count("jobs.failed", value: 1, attributes: attrs.merge(error_class: error.class.name))
        raise
      ensure
        elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000
        SentryMetrics.distribution("jobs.duration", elapsed_ms, unit: "millisecond", attributes: attrs)
      end
    end
  end

  private

  def safe_argument_types(arguments)
    Array(arguments).map { |argument| argument.class.name }
  end

  def sentry_job_arg_types_enabled?
    ENV.fetch("SENTRY_JOB_ARG_TYPES_ENABLED", "true") == "true"
  end

  def metric_attributes(job)
    {
      job_class: job.class.name,
      queue: job.queue_name,
      adapter: ActiveJob::Base.queue_adapter.class.name
    }
  end
end
