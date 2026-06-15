require "rails_helper"

RSpec.describe AnalyticsDailyRollup, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:period_date) }
    it { is_expected.to validate_presence_of(:controller_name) }
    it { is_expected.to validate_presence_of(:action_name) }
  end

  describe ".for_range" do
    before do
      AnalyticsDailyRollup.create!(period_date: 2.days.ago.to_date, controller_name: "rooms", action_name: "index", total_views: 10)
      AnalyticsDailyRollup.create!(period_date: 40.days.ago.to_date, controller_name: "rooms", action_name: "index", total_views: 5)
    end

    it "returns rows within the 7d window" do
      result = described_class.for_range("7d")
      expect(result.map(&:total_views)).to include(10)
      expect(result.map(&:total_views)).not_to include(5)
    end

    it "returns rows within the 30d window" do
      result = described_class.for_range("30d")
      expect(result.map(&:total_views)).to include(10)
      expect(result.map(&:total_views)).not_to include(5)
    end
  end

  describe ".top_pages" do
    before do
      AnalyticsDailyRollup.create!(period_date: 1.day.ago.to_date, controller_name: "rooms",     action_name: "index", total_views: 50)
      AnalyticsDailyRollup.create!(period_date: 1.day.ago.to_date, controller_name: "buildings", action_name: "index", total_views: 20)
    end

    it "returns pages ordered by views descending" do
      top = described_class.all.top_pages(5)
      expect(top.first[:page]).to eq("rooms#index")
      expect(top.second[:page]).to eq("buildings#index")
    end
  end

  describe ".summary_stats" do
    before do
      AnalyticsDailyRollup.create!(period_date: 1.day.ago.to_date, controller_name: "rooms", action_name: "index",
        total_views: 100, unique_sessions: 80, unique_users: 60, authenticated_views: 90)
    end

    it "sums across all rows" do
      stats = described_class.all.summary_stats
      expect(stats[:total_views]).to eq(100)
      expect(stats[:unique_users]).to eq(60)
    end
  end
end
