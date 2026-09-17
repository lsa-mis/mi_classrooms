require "rails_helper"

RSpec.describe AnalyticsHourlyRollup, type: :model do
  describe "validations" do
    it "requires period_start" do
      rollup = described_class.new(controller_name: "rooms", action_name: "index")
      expect(rollup).not_to be_valid
      expect(rollup.errors[:period_start]).to be_present
    end

    it "requires controller_name and action_name" do
      rollup = described_class.new(period_start: 1.hour.ago.beginning_of_hour)
      expect(rollup).not_to be_valid
      expect(rollup.errors[:controller_name]).to be_present
      expect(rollup.errors[:action_name]).to be_present
    end
  end

  describe ".for_range" do
    before do
      described_class.create!(
        period_start: 2.hours.ago.beginning_of_hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 10
      )
      described_class.create!(
        period_start: 40.hours.ago.beginning_of_hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 5
      )
      described_class.create!(
        period_start: 10.days.ago.beginning_of_hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 3
      )
      described_class.create!(
        period_start: 40.days.ago.beginning_of_hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 1
      )
    end

    it "returns rows within the 24h window" do
      result = described_class.for_range("24h")
      expect(result.map(&:total_views)).to include(10)
      expect(result.map(&:total_views)).not_to include(5)
      expect(result.map(&:total_views)).not_to include(3, 1)
    end

    it "returns rows within the 7d window" do
      result = described_class.for_range("7d")
      expect(result.map(&:total_views)).to include(10, 5)
      expect(result.map(&:total_views)).not_to include(3, 1)
    end

    it "returns rows within the 30d window" do
      result = described_class.for_range("30d")
      expect(result.map(&:total_views)).to include(10, 5, 3)
      expect(result.map(&:total_views)).not_to include(1)
    end

    it "defaults unknown ranges to the 7d window" do
      result = described_class.for_range("bogus")
      expect(result.map(&:total_views)).to include(10, 5)
      expect(result.map(&:total_views)).not_to include(3, 1)
    end
  end

  describe ".totals_by_hour" do
    let(:hour) { 1.hour.ago.beginning_of_hour }

    before do
      described_class.create!(
        period_start: hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 10,
        unique_sessions: 8,
        unique_users: 6,
        authenticated_views: 9
      )
      described_class.create!(
        period_start: hour,
        controller_name: "buildings",
        action_name: "show",
        total_views: 5,
        unique_sessions: 4,
        unique_users: 3,
        authenticated_views: 2
      )
    end

    it "sums metrics across controller/action rows for the same hour" do
      totals = described_class.all.totals_by_hour
      expect(totals).to eq([
        {
          hour: hour,
          total_views: 15,
          unique_sessions: 12,
          unique_users: 9,
          authenticated_views: 11
        }
      ])
    end
  end

  describe ".summary_stats" do
    before do
      described_class.create!(
        period_start: 1.hour.ago.beginning_of_hour,
        controller_name: "rooms",
        action_name: "index",
        total_views: 100,
        unique_sessions: 80,
        unique_users: 60,
        authenticated_views: 90
      )
      described_class.create!(
        period_start: 2.hours.ago.beginning_of_hour,
        controller_name: "buildings",
        action_name: "show",
        total_views: 20,
        unique_sessions: 10,
        unique_users: 5,
        authenticated_views: 8
      )
    end

    it "sums all four metrics across controller/action rows" do
      stats = described_class.all.summary_stats
      expect(stats).to eq(
        total_views: 120,
        unique_sessions: 90,
        unique_users: 65,
        authenticated_views: 98
      )
    end
  end
end
