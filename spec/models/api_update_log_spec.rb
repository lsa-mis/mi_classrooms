require "rails_helper"

RSpec.describe ApiUpdateLog, type: :model do
  describe "persistence" do
    it "can be created with a result summary and status" do
      log = described_class.create!(result: "nightly update finished in 10 minutes", status: "success")

      expect(log).to be_persisted
      expect(log.status).to eq("success")
      expect(log.result).to include("nightly update")
    end

    it "stores the error status used by the task logger" do
      log = described_class.create!(result: "department sync failed", status: "error")

      expect(log.status).to eq("error")
      expect(log.result).to eq("department sync failed")
    end
  end

  describe "#structured_report" do
    it "parses the saved structured report JSON" do
      log = described_class.create!(
        status: "success",
        result: <<~TEXT
          Time report:
          Update campus list Time: 1.2 seconds

          Structured report:
          {
            "status": "success",
            "duration_seconds": 72.5,
            "phases": [
              {
                "phase": "Update campus list",
                "status": "success",
                "counters": {
                  "updated": 3
                }
              }
            ]
          }
        TEXT
      )

      expect(log.structured_report["status"]).to eq("success")
      expect(log.structured_report["phases"].first["counters"]["updated"]).to eq(3)
      expect(log.summary_text).to include("Time report")
      expect(log.summary_text).not_to include("Structured report")
    end

    it "returns nil for legacy reports without structured JSON" do
      log = described_class.create!(status: "success", result: "Time report only")

      expect(log.structured_report).to be_nil
      expect(log.summary_text).to eq("Time report only")
    end

    it "extracts JSON from a structured report with trailing text" do
      log = described_class.create!(
        status: "success",
        result: <<~TEXT
          Time report:
          Update Rooms Time: 1.0 seconds

          Structured report:
          {
            "status": "success",
            "phases": []
          }
          trailing non-json text
        TEXT
      )

      expect(log.structured_report).to eq({"status" => "success", "phases" => []})
    end
  end

  describe "#report_for_display" do
    it "parses phase counters and warnings from a legacy report" do
      log = described_class.create!(
        status: "success",
        result: <<~TEXT
          Time report:
          Update Rooms Time: 12.34 seconds
            Counts: updated=12, deactivated=3
            Warning: update_rooms, deactivated stale rooms
        TEXT
      )

      report = log.report_for_display

      expect(report["phases"].size).to eq(1)
      expect(report["phases"].first["phase"]).to eq("Update Rooms")
      expect(report["phases"].first["counters"]).to eq({"updated" => 12, "deactivated" => 3})
      expect(report["phases"].first["warnings"]).to eq(["update_rooms, deactivated stale rooms"])
    end
  end
end
