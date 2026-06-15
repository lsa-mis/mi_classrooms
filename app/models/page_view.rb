class PageView < ApplicationRecord
  belongs_to :user, optional: true

  validates :session_token, presence: true, length: {maximum: 32}
  validates :controller_name, presence: true
  validates :action_name, presence: true
  validates :path, presence: true
  validates :occurred_at, presence: true

  # Aggregate one hour window into a hash suitable for upserting into hourly rollups.
  # Returns an array of hashes, one per controller+action combination.
  def self.rollup_hourly(period_start)
    period_end = period_start + 1.hour
    where(occurred_at: period_start...period_end)
      .group(:controller_name, :action_name)
      .select(
        :controller_name,
        :action_name,
        "COUNT(*) AS total_views",
        "COUNT(DISTINCT session_token) AS unique_sessions",
        "COUNT(DISTINCT user_id) AS unique_users",
        "COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) AS authenticated_views",
        "AVG(duration_ms)::integer AS avg_duration_ms"
      )
      .map { |r| r.attributes.slice("controller_name", "action_name", "total_views", "unique_sessions", "unique_users", "authenticated_views", "avg_duration_ms") }
  end

  # Aggregate one calendar day into a hash suitable for upserting into daily rollups.
  def self.rollup_daily(date)
    where(occurred_at: date.beginning_of_day...date.end_of_day)
      .group(:controller_name, :action_name)
      .select(
        :controller_name,
        :action_name,
        "COUNT(*) AS total_views",
        "COUNT(DISTINCT session_token) AS unique_sessions",
        "COUNT(DISTINCT user_id) AS unique_users",
        "COUNT(CASE WHEN user_id IS NOT NULL THEN 1 END) AS authenticated_views",
        "AVG(duration_ms)::integer AS avg_duration_ms"
      )
      .map { |r| r.attributes.slice("controller_name", "action_name", "total_views", "unique_sessions", "unique_users", "authenticated_views", "avg_duration_ms") }
  end

  def self.prune_before!(cutoff)
    where("occurred_at < ?", cutoff).delete_all
  end
end
