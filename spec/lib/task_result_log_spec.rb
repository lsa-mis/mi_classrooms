# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskResultLog do
  describe "#update_log" do
    it "persists a success ApiUpdateLog when debug is false" do
      expect {
        described_class.new.update_log("nightly run finished", false)
      }.to change(ApiUpdateLog, :count).by(1)

      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.status).to eq("success")
      expect(log.result).to eq("nightly run finished")
    end

    it "persists an error ApiUpdateLog when debug is true" do
      described_class.new.update_log("token acquisition failed", true)

      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.status).to eq("error")
      expect(log.result).to eq("token acquisition failed")
    end

    it "appends a pretty-printed structured report payload when present" do
      payload = {
        "status" => "error",
        "phases" => [
          {"phase" => "Update buildings", "status" => "error", "errors" => ["boom"]}
        ]
      }

      described_class.new.update_log("Time report:\nUpdate buildings failed", true, payload)

      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.status).to eq("error")
      expect(log.result).to include("Time report:")
      expect(log.result).to include("Structured report:")
      expect(log.result).to include(JSON.pretty_generate(payload))
      expect(log.structured_report["status"]).to eq("error")
      expect(log.structured_report["phases"].first["phase"]).to eq("Update buildings")
    end

    it "does not append a structured report section when payload is blank" do
      described_class.new.update_log("plain summary only", false, nil)

      log = ApiUpdateLog.order(created_at: :desc).first
      expect(log.result).to eq("plain summary only")
      expect(log.result).not_to include("Structured report:")
    end

    it "falls back to the api logger when the ApiUpdateLog cannot be saved" do
      api_log = instance_double(ApiLog)
      logger = instance_double(Logger)
      invalid_record = ApiUpdateLog.new(result: "x", status: "success")

      allow(ApiLog).to receive(:new).and_return(api_log)
      allow(api_log).to receive(:api_logger).and_return(logger)
      allow(ApiUpdateLog).to receive(:new).and_return(invalid_record)
      allow(invalid_record).to receive(:save).and_return(false)
      expect(logger).to receive(:debug).with(
        "api_update_log, error: Could not save: record.errors.full_messages"
      )

      expect {
        described_class.new.update_log("unsavable", false)
      }.not_to change(ApiUpdateLog, :count)
    end
  end
end
