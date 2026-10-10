require "rails_helper"

RSpec.describe SentryMetrics do
  before do
    allow(Rails.logger).to receive(:debug)
  end

  describe ".count" do
    it "forwards the metric with app and environment attributes" do
      allow(Sentry::Metrics).to receive(:count)

      described_class.count("jobs.started", value: 2, attributes: {job: "SyncJob"})

      expect(Sentry::Metrics).to have_received(:count).with(
        "jobs.started",
        value: 2,
        attributes: hash_including(app: "mi_classrooms", environment: Rails.env, job: "SyncJob")
      )
    end

    it "swallows Sentry failures so callers are not interrupted" do
      allow(Sentry::Metrics).to receive(:count).and_raise(StandardError, "sentry down")

      expect { described_class.count("jobs.started") }.not_to raise_error
      expect(Rails.logger).to have_received(:debug).with(/Sentry metric count failed for jobs.started/)
    end
  end

  describe ".gauge" do
    it "forwards an optional unit and merges base attributes" do
      allow(Sentry::Metrics).to receive(:gauge)

      described_class.gauge("queue.depth", 4, unit: "none", attributes: {queue: "default"})

      expect(Sentry::Metrics).to have_received(:gauge).with(
        "queue.depth",
        4.0,
        unit: "none",
        attributes: hash_including(app: "mi_classrooms", environment: Rails.env, queue: "default")
      )
    end

    it "swallows Sentry failures so callers are not interrupted" do
      allow(Sentry::Metrics).to receive(:gauge).and_raise(StandardError, "sentry down")

      expect { described_class.gauge("queue.depth", 1) }.not_to raise_error
      expect(Rails.logger).to have_received(:debug).with(/Sentry metric gauge failed for queue.depth/)
    end
  end

  describe ".distribution" do
    it "forwards an optional unit and merges base attributes" do
      allow(Sentry::Metrics).to receive(:distribution)

      described_class.distribution("jobs.duration", 12.5, unit: "millisecond", attributes: {job: "SyncJob"})

      expect(Sentry::Metrics).to have_received(:distribution).with(
        "jobs.duration",
        12.5,
        unit: "millisecond",
        attributes: hash_including(app: "mi_classrooms", environment: Rails.env, job: "SyncJob")
      )
    end

    it "omits the unit keyword when none is provided" do
      allow(Sentry::Metrics).to receive(:distribution)

      described_class.distribution("jobs.duration", 3)

      expect(Sentry::Metrics).to have_received(:distribution).with(
        "jobs.duration",
        3.0,
        attributes: hash_including(app: "mi_classrooms", environment: Rails.env)
      )
    end

    it "swallows Sentry failures so callers are not interrupted" do
      allow(Sentry::Metrics).to receive(:distribution).and_raise(StandardError, "sentry down")

      expect { described_class.distribution("jobs.duration", 1) }.not_to raise_error
      expect(Rails.logger).to have_received(:debug).with(/Sentry metric distribution failed for jobs.duration/)
    end
  end
end
