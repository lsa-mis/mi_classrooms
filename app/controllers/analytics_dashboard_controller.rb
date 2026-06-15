class AnalyticsDashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :analytics_dashboard, :index?

    @range = sanitize_range(params[:range])
    since  = range_cutoff(@range)

    # Charts read from rollup tables (populated by AnalyticsRollupJob on schedule).
    @hourly_series = AnalyticsHourlyRollup.for_range(@range).totals_by_hour
    @daily_series  = AnalyticsDailyRollup.for_range(@range).totals_by_day

    # Top pages and summary always read live from page_views so they reflect
    # current data immediately, without waiting for the rollup job to run.
    @top_pages = if AnalyticsDailyRollup.for_range(@range).exists?
      AnalyticsDailyRollup.for_range(@range).top_pages(10)
    else
      PageView.live_top_pages(since: since, limit: 10)
    end

    @summary       = PageView.live_summary(since: since)
    @rollup_stale  = @hourly_series.empty? && @daily_series.empty?

    @page_title = "Analytics Dashboard"
  end

  # Triggers rollup jobs synchronously so chart data appears immediately.
  # Useful in development and after a job outage.
  def refresh
    authorize :analytics_dashboard, :refresh?

    range = sanitize_range(params[:range])
    run_rollups_for_range(range)

    redirect_to analytics_dashboard_path(range: range), notice: "Charts refreshed."
  end

  private

  def sanitize_range(value)
    %w[24h 7d 30d].include?(value) ? value : "7d"
  end

  def range_cutoff(range)
    case range
    when "24h" then 24.hours.ago
    when "7d"  then 7.days.ago
    when "30d" then 30.days.ago
    else 7.days.ago
    end
  end

  def run_rollups_for_range(range)
    # Roll up every hour in the selected range into hourly rollups,
    # and every calendar day into daily rollups.
    cutoff = range_cutoff(range)
    hour   = cutoff.beginning_of_hour

    while hour <= Time.current.beginning_of_hour
      AnalyticsRollupJob.perform_now(period_type: "hourly", target: hour.iso8601)
      hour += 1.hour
    end

    date = cutoff.to_date
    while date <= Date.today
      AnalyticsRollupJob.perform_now(period_type: "daily", target: date.to_s)
      date += 1.day
    end
  end
end
