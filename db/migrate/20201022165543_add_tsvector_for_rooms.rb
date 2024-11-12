class AddTsvectorForRooms < ActiveRecord::Migration[6.0]
  def up
    add_column :rooms, :tsv, :tsvector
    add_index :rooms, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON rooms FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', room_number, facility_code_heprod
      );
    SQL
  end

  def down
    remove_index :rooms, :tsv
    remove_column :rooms, :tsv
    execute <<-SQL
      DROP TRIGGER IF EXISTS tsvectorupdate ON rooms;
    SQL
  end
end
