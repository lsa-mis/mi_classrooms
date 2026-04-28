class AddUniqueIdIndexToSolidCableMessages < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:solid_cable_messages)
    return unless column_exists?(:solid_cable_messages, :id)

    unless index_exists?(:solid_cable_messages, :id, unique: true, name: "index_solid_cable_messages_on_id")
      add_index :solid_cable_messages, :id, unique: true, name: "index_solid_cable_messages_on_id"
    end
  end

  def down
    return unless table_exists?(:solid_cable_messages)

    if index_exists?(:solid_cable_messages, :id, unique: true, name: "index_solid_cable_messages_on_id")
      remove_index :solid_cable_messages, name: "index_solid_cable_messages_on_id"
    end
  end
end
