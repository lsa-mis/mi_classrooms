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
end
