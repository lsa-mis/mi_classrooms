class AnalyticsDashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :analytics_dashboard, :index?

    @range = sanitize_range(params[:range])

    @hourly_series = AnalyticsHourlyRollup.for_range(@range).totals_by_hour
    @daily_series  = AnalyticsDailyRollup.for_range(@range).totals_by_day
    @top_pages     = AnalyticsDailyRollup.for_range(@range).top_pages(10)
    @summary       = AnalyticsDailyRollup.for_range(@range).summary_stats

    @page_title = "Analytics Dashboard"
  end

  private

  def sanitize_range(value)
    %w[24h 7d 30d].include?(value) ? value : "7d"
  end
end
