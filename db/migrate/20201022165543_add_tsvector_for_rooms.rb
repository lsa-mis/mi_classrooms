class AddTsvectorForRooms < ActiveRecord::Migration[6.1]
  def up
    add_column :rooms, :tsv, :tsvector
    add_index :rooms, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON rooms FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english',  room_number, facility_code_heprod
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE rooms SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON rooms
    SQL

    remove_index :rooms, :tsv
    remove_column :rooms, :tsv
  end
end
