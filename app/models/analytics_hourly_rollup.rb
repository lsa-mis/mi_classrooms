class AnalyticsHourlyRollup < ApplicationRecord
  validates :period_start, presence: true
  validates :controller_name, presence: true
  validates :action_name, presence: true

  scope :for_range, ->(range) {
    cutoff = case range
             when "24h" then 24.hours.ago.beginning_of_hour
             when "7d"  then 7.days.ago.beginning_of_hour
             when "30d" then 30.days.ago.beginning_of_hour
             else 7.days.ago.beginning_of_hour
             end
    where("period_start >= ?", cutoff).order(:period_start)
  }

  scope :for_controller, ->(name) { where(controller_name: name) }

  # Returns [{hour:, total_views:, unique_sessions:, unique_users:, authenticated_views:}, ...]
  # grouped by hour (summed across all controller+action combos).
  def self.totals_by_hour
    all.group(:period_start)
      .select(
        :period_start,
        "SUM(total_views) AS total_views",
        "SUM(unique_sessions) AS unique_sessions",
        "SUM(unique_users) AS unique_users",
        "SUM(authenticated_views) AS authenticated_views"
      )
      .order(:period_start)
      .map { |r| {hour: r.period_start, total_views: r.total_views, unique_sessions: r.unique_sessions, unique_users: r.unique_users, authenticated_views: r.authenticated_views} }
  end

  def self.summary_stats
    rows = all.to_a
    {
      total_views: rows.sum(&:total_views),
      unique_sessions: rows.map(&:unique_sessions).sum,
      unique_users: rows.map(&:unique_users).sum,
      authenticated_views: rows.sum(&:authenticated_views)
    }
  end
end
