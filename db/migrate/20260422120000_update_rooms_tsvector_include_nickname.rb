class UpdateRoomsTsvectorIncludeNickname < ActiveRecord::Migration[8.1]
  def up
    execute "DROP TRIGGER IF EXISTS tsvectorupdate ON rooms"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON rooms FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', room_number, facility_code_heprod, nickname
      );
    SQL

    say_with_time "Refreshing rooms.tsv for full-text search" do
      execute "UPDATE rooms SET updated_at = updated_at"
    end
  end

  def down
    execute "DROP TRIGGER IF EXISTS tsvectorupdate ON rooms"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON rooms FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', room_number, facility_code_heprod
      );
    SQL

    execute "UPDATE rooms SET updated_at = updated_at"
  end
end
