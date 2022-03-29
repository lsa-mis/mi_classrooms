class CreateApiUpdateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :api_update_logs do |t|
      t.text :result, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
