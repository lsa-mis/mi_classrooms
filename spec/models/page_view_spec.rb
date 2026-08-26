require "rails_helper"

RSpec.describe PageView, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:session_token) }
    it { is_expected.to validate_presence_of(:controller_name) }
    it { is_expected.to validate_presence_of(:action_name) }
    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:occurred_at) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe ".rollup_hourly" do
    let(:period_start) { Time.current.beginning_of_hour }

    before do
      # 3 views from 2 sessions, 1 authenticated
      create(:page_view, session_token: "aaaa" * 8, user: nil,           occurred_at: period_start + 1.minute, controller_name: "rooms", action_name: "index", duration_ms: 100)
      create(:page_view, session_token: "aaaa" * 8, user: nil,           occurred_at: period_start + 2.minutes, controller_name: "rooms", action_name: "index", duration_ms: 200)
      create(:page_view, :authenticated, session_token: "bbbb" * 8,      occurred_at: period_start + 3.minutes, controller_name: "rooms", action_name: "index", duration_ms: 300)
      # outside the window — should not be counted
      create(:page_view, occurred_at: period_start - 1.minute, controller_name: "rooms", action_name: "index")
    end

    it "counts total views for the hour" do
      result = described_class.rollup_hourly(period_start)
      row = result.find { |r| r["controller_name"] == "rooms" && r["action_name"] == "index" }
      expect(row["total_views"]).to eq(3)
    end

    it "counts unique sessions" do
      result = described_class.rollup_hourly(period_start)
      row = result.find { |r| r["controller_name"] == "rooms" }
      expect(row["unique_sessions"]).to eq(2)
    end

    it "counts authenticated views" do
      result = described_class.rollup_hourly(period_start)
      row = result.find { |r| r["controller_name"] == "rooms" }
      expect(row["authenticated_views"]).to eq(1)
    end
  end

  describe ".prune_before!" do
    it "deletes rows older than the cutoff and keeps recent ones" do
      old = create(:page_view, occurred_at: 91.days.ago)
      recent = create(:page_view, occurred_at: 1.day.ago)

      described_class.prune_before!(90.days.ago)

      expect(PageView.where(id: old.id)).to be_empty
      expect(PageView.where(id: recent.id)).to exist
    end
  end

  describe ".live_summary" do
    let(:since) { 7.days.ago }

    before do
      create(:page_view, session_token: "aaaa" * 8, user: nil, occurred_at: 1.day.ago)
      create(:page_view, session_token: "aaaa" * 8, user: nil, occurred_at: 2.days.ago)
      create(:page_view, :authenticated, session_token: "bbbb" * 8, occurred_at: 3.days.ago)
      # Outside the window — must not be counted
      create(:page_view, session_token: "cccc" * 8, occurred_at: 10.days.ago)
    end

    it "aggregates live totals from raw page_views within the window" do
      summary = described_class.live_summary(since: since)

      expect(summary).to eq(
        total_views: 3,
        unique_sessions: 2,
        unique_users: 1,
        authenticated_views: 1
      )
    end
  end

  describe ".live_top_pages" do
    let(:since) { 7.days.ago }

    before do
      3.times { create(:page_view, controller_name: "rooms", action_name: "index", occurred_at: 1.day.ago) }
      2.times { create(:page_view, controller_name: "buildings", action_name: "show", occurred_at: 2.days.ago) }
      create(:page_view, controller_name: "pages", action_name: "home", occurred_at: 3.days.ago)
      create(:page_view, controller_name: "rooms", action_name: "index", occurred_at: 10.days.ago)
    end

    it "returns pages ranked by live view count within the window" do
      pages = described_class.live_top_pages(since: since, limit: 2)

      expect(pages.length).to eq(2)
      expect(pages.first).to include(page: "rooms#index", total_views: 3)
      expect(pages.second).to include(page: "buildings#show", total_views: 2)
    end

    it "respects the limit" do
      pages = described_class.live_top_pages(since: since, limit: 1)

      expect(pages.length).to eq(1)
      expect(pages.first[:page]).to eq("rooms#index")
    end
  end
end
