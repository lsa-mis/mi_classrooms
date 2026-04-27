require "rails_helper"

RSpec.describe ApiUpdateDatabase::Runner do
  describe "#run" do
    it "writes a structured ApiUpdateLog for successful phases" do
      api = double("FakeApi")
      phase_result = ApiUpdateDatabase::PhaseResult.new("Fake phase")
      phase_result.increment(:updated, 2)

      phase = described_class::Phase.new(
        time_label: "Fake phase",
        failure_label: "Fake phase failed.",
        api_factory: ->(_) { api },
        method_name: :perform_update
      )

      stub_const("#{described_class}::PHASES", [phase])
      allow(api).to receive(:perform_update).and_return(false)
      allow(api).to receive(:respond_to?).with(:last_result).and_return(true)
      allow(api).to receive(:last_result).and_return(phase_result)

      result = described_class.new(sleeper: ->(_) {}).run

      expect(result).to be_success
      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.status).to eq("success")
      expect(log.result).to include("Structured report")
      expect(log.result).to include("\"updated\": 2")
    end

    it "keeps API phase data when an after-success job fails" do
      api = double("FakeApi")
      phase_result = ApiUpdateDatabase::PhaseResult.new("Fake phase")
      phase_result.increment(:updated, 2)

      phase = described_class::Phase.new(
        time_label: "Fake phase",
        failure_label: "Fake phase failed.",
        api_factory: ->(_) { api },
        method_name: :perform_update,
        after_success: -> { raise "after-success boom" }
      )

      stub_const("#{described_class}::PHASES", [phase])
      allow(api).to receive(:perform_update).and_return(false)
      allow(api).to receive(:respond_to?).with(:last_result).and_return(true)
      allow(api).to receive(:last_result).and_return(phase_result)

      result = described_class.new(sleeper: ->(_) {}).run
      phase = result.phases.first

      expect(result).not_to be_success
      expect(phase.counters[:updated]).to eq(2)
      expect(phase.errors.join).to include("after-success boom")
    end

    it "skips after-success jobs in delete dry-run mode" do
      api = double("FakeApi")
      after_success = double("after_success")
      phase_result = ApiUpdateDatabase::PhaseResult.new("Fake phase")

      phase = described_class::Phase.new(
        time_label: "Fake phase",
        failure_label: "Fake phase failed.",
        api_factory: ->(_) { api },
        method_name: :perform_update,
        after_success: after_success
      )

      stub_const("#{described_class}::PHASES", [phase])
      allow(api).to receive(:perform_update).and_return(false)
      allow(api).to receive(:respond_to?).with(:last_result).and_return(true)
      allow(api).to receive(:last_result).and_return(phase_result)

      expect(after_success).not_to receive(:call)

      result = described_class.new(delete_dry_run: true, sleeper: ->(_) {}).run

      expect(result).to be_success
      expect(result.phases.first.warnings.join).to include("delete dry run")
    end

    it "records the phase failure when the API factory raises" do
      phase = described_class::Phase.new(
        time_label: "Fake phase",
        failure_label: "Fake phase failed.",
        api_factory: ->(_) { raise "factory boom" },
        method_name: :perform_update
      )

      stub_const("#{described_class}::PHASES", [phase])

      result = described_class.new(sleeper: ->(_) {}).run
      phase = result.phases.first

      expect(result).not_to be_success
      expect(phase.phase).to eq("Fake phase")
      expect(phase.errors.join).to include("factory boom")
    end
  end
end
