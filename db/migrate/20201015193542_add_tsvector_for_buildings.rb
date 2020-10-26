class AddTsvectorForBuildings < ActiveRecord::Migration[6.1]

  def up
    add_column :buildings, :tsv, :tsvector
    add_index :buildings, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON buildings FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', name, nick_name, abbreviation
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE buildings SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON buildings
    SQL

    remove_index :buildings, :tsv
    remove_column :buildings, :tsv
  end
end