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

    it "stops the run when token acquisition fails and skips later phases" do
      token_api = instance_double(AuthTokenApi)
      later_factory = double("later_factory")

      token_phase = described_class::Phase.new(
        time_label: "Update campus list",
        failure_label: "Campus updates failed.",
        api_factory: ->(_) { raise "should not build API without a token" },
        method_name: :update_campus_list,
        token_scope: "buildings",
        token_action_name: "update_campus_list",
        token_error_heading: "Update Campuses"
      )
      later_phase = described_class::Phase.new(
        time_label: "Update buildings",
        failure_label: "Buildings updates failed.",
        api_factory: later_factory,
        method_name: :update_all_buildings
      )

      stub_const("#{described_class}::PHASES", [token_phase, later_phase])
      allow(AuthTokenApi).to receive(:new).with("buildings").and_return(token_api)
      allow(token_api).to receive(:get_auth_token).and_return(
        "success" => false,
        "error" => "invalid_client"
      )
      expect(later_factory).not_to receive(:call)

      result = described_class.new(sleeper: ->(_) {}).run

      expect(result).not_to be_success
      expect(result.phases.size).to eq(1)
      expect(result.phases.first.phase).to eq("Update campus list token")
      expect(result.phases.first.errors.join).to include("Update Campuses")
      expect(result.phases.first.errors.join).to include("invalid_client")

      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.status).to eq("error")
      expect(log.result).to include("Structured report")
      expect(log.result).to include("invalid_client")
    end

    it "records a phase error when the API signals failure without its own errors" do
      api = double("FakeApi")
      phase = described_class::Phase.new(
        time_label: "Fake phase",
        failure_label: "Fake phase failed.",
        api_factory: ->(_) { api },
        method_name: :perform_update
      )

      stub_const("#{described_class}::PHASES", [phase])
      allow(api).to receive(:perform_update).and_return(true)
      allow(api).to receive(:respond_to?).with(:last_result).and_return(false)

      result = described_class.new(sleeper: ->(_) {}).run

      expect(result).not_to be_success
      expect(result.phases.first.errors.join).to include("Fake phase failed.")
      expect(result.phases.first.errors.join).to include("api_nightly_update_db.log")
    end
  end
end
