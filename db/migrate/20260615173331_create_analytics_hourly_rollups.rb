class CreateAnalyticsHourlyRollups < ActiveRecord::Migration[8.1]
  def change
    create_table :analytics_hourly_rollups do |t|
      t.datetime :period_start,         null: false
      t.string   :controller_name,      null: false, limit: 100
      t.string   :action_name,          null: false, limit: 100
      t.integer  :total_views,          null: false, default: 0
      t.integer  :unique_sessions,      null: false, default: 0
      t.integer  :unique_users,         null: false, default: 0
      t.integer  :authenticated_views,  null: false, default: 0
      t.integer  :avg_duration_ms
      t.timestamps
    end

    add_index :analytics_hourly_rollups, :period_start
    add_index :analytics_hourly_rollups,
              [:period_start, :controller_name, :action_name],
              unique: true,
              name: "idx_hourly_rollup_period_action"
  end
end
