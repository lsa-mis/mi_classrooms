class AnalyticsRollupJob < ApplicationJob
  queue_as :analytics

  PRUNE_AFTER = 90.days

  # period_type: "hourly" | "daily" | "prune"
  # target: ISO8601 string for hourly/daily, or nil to use the previous period
  def perform(period_type: "hourly", target: nil)
    case period_type.to_s
    when "hourly"
      hour = target ? Time.zone.parse(target) : 1.hour.ago.beginning_of_hour
      rollup_hour(hour)
    when "daily"
      date = target ? Date.parse(target) : Date.yesterday
      rollup_day(date)
    when "prune"
      PageView.prune_before!(PRUNE_AFTER.ago)
    else
      raise ArgumentError, "Unknown period_type: #{period_type}"
    end
  end

  private

  def rollup_hour(period_start)
    rows = PageView.rollup_hourly(period_start)
    rows.each do |attrs|
      AnalyticsHourlyRollup.upsert(
        attrs.merge(period_start: period_start, created_at: Time.current, updated_at: Time.current),
        unique_by: :idx_hourly_rollup_period_action
      )
    end
  end

  def rollup_day(date)
    rows = PageView.rollup_daily(date)
    rows.each do |attrs|
      AnalyticsDailyRollup.upsert(
        attrs.merge(period_date: date, created_at: Time.current, updated_at: Time.current),
        unique_by: :idx_daily_rollup_period_action
      )
    end
  end
end
