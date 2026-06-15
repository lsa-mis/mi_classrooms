class AnalyticsDailyRollup < ApplicationRecord
  validates :period_date, presence: true
  validates :controller_name, presence: true
  validates :action_name, presence: true

  scope :for_range, ->(range) {
    cutoff = case range
             when "24h" then Date.today
             when "7d"  then 7.days.ago.to_date
             when "30d" then 30.days.ago.to_date
             else 7.days.ago.to_date
             end
    where("period_date >= ?", cutoff).order(:period_date)
  }

  scope :for_controller, ->(name) { where(controller_name: name) }

  # Returns [{date:, total_views:, unique_sessions:, unique_users:, authenticated_views:}, ...]
  # summed across all controller+action combos per day.
  def self.totals_by_day
    group(:period_date)
      .select(
        :period_date,
        "SUM(total_views) AS total_views",
        "SUM(unique_sessions) AS unique_sessions",
        "SUM(unique_users) AS unique_users",
        "SUM(authenticated_views) AS authenticated_views"
      )
      .order(:period_date)
      .map { |r| {date: r.period_date, total_views: r.total_views, unique_sessions: r.unique_sessions, unique_users: r.unique_users, authenticated_views: r.authenticated_views} }
  end

  # Top pages by total views over the scoped period.
  def self.top_pages(limit = 10)
    # reorder clears any inherited ORDER BY (e.g. from for_range scope) that
    # would conflict with the GROUP BY on controller_name+action_name.
    reorder(nil)
      .group(:controller_name, :action_name)
      .select(
        :controller_name,
        :action_name,
        "SUM(total_views) AS total_views",
        "SUM(unique_sessions) AS unique_sessions",
        "SUM(unique_users) AS unique_users"
      )
      .order("SUM(total_views) DESC")
      .limit(limit)
      .map { |r| {page: "#{r.controller_name}##{r.action_name}", total_views: r.total_views, unique_sessions: r.unique_sessions, unique_users: r.unique_users} }
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
