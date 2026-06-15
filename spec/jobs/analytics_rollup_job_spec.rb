require "rails_helper"

RSpec.describe AnalyticsRollupJob, type: :job do
  let(:period_start) { 2.hours.ago.beginning_of_hour }

  before do
    # Two views in the target hour from two different sessions
    create(:page_view,
      session_token: "aaaa" * 8,
      controller_name: "rooms",
      action_name: "index",
      occurred_at: period_start + 5.minutes,
      duration_ms: 100)
    create(:page_view, :authenticated,
      session_token: "bbbb" * 8,
      controller_name: "rooms",
      action_name: "index",
      occurred_at: period_start + 10.minutes,
      duration_ms: 200)
  end

  describe "hourly rollup" do
    it "creates an hourly rollup row" do
      expect { described_class.perform_now(period_type: "hourly", target: period_start.iso8601) }
        .to change(AnalyticsHourlyRollup, :count).by(1)
    end

    it "aggregates correctly" do
      described_class.perform_now(period_type: "hourly", target: period_start.iso8601)
      row = AnalyticsHourlyRollup.last
      expect(row.total_views).to eq(2)
      expect(row.unique_sessions).to eq(2)
      expect(row.authenticated_views).to eq(1)
    end

    it "is idempotent (re-run upserts, does not duplicate)" do
      described_class.perform_now(period_type: "hourly", target: period_start.iso8601)
      expect { described_class.perform_now(period_type: "hourly", target: period_start.iso8601) }
        .not_to change(AnalyticsHourlyRollup, :count)
    end
  end

  describe "daily rollup" do
    let(:target_date) { period_start.to_date }

    it "creates a daily rollup row" do
      expect { described_class.perform_now(period_type: "daily", target: target_date.to_s) }
        .to change(AnalyticsDailyRollup, :count).by(1)
    end

    it "is idempotent" do
      described_class.perform_now(period_type: "daily", target: target_date.to_s)
      expect { described_class.perform_now(period_type: "daily", target: target_date.to_s) }
        .not_to change(AnalyticsDailyRollup, :count)
    end
  end

  describe "prune" do
    it "deletes rows older than 90 days" do
      old = create(:page_view, occurred_at: 95.days.ago)
      described_class.perform_now(period_type: "prune")
      expect(PageView.where(id: old.id)).to be_empty
    end

    it "keeps rows within 90 days" do
      recent = create(:page_view, occurred_at: 1.day.ago)
      described_class.perform_now(period_type: "prune")
      expect(PageView.where(id: recent.id)).to exist
    end
  end

  it "runs on the analytics queue" do
    expect(described_class.new.queue_name).to eq("analytics")
  end
end
