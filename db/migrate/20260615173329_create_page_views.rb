class CreatePageViews < ActiveRecord::Migration[8.1]
  def change
    create_table :page_views do |t|
      t.string   :session_token,   null: false, limit: 32
      t.bigint   :user_id
      t.string   :controller_name, null: false, limit: 100
      t.string   :action_name,     null: false, limit: 100
      t.string   :path,            null: false, limit: 500
      t.string   :referrer_host,   limit: 255
      t.string   :device_type,     limit: 20
      t.integer  :http_status, limit: 2
      t.integer  :duration_ms
      t.datetime :occurred_at,     null: false, precision: 6
    end

    add_index :page_views, :occurred_at
    add_index :page_views, :user_id
    add_index :page_views, :session_token
  end
end
