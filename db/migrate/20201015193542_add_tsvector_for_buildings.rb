class AddTsvectorForBuildings < ActiveRecord::Migration[6.0]

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
  end

  def down
    remove_index :buildings, :tsv
    remove_column :buildings, :tsv
    execute <<-SQL
      DROP TRIGGER IF EXISTS tsvectorupdate ON buildings;
    SQL
  end
end