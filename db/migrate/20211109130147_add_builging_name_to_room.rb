class AddBuilgingNameToRoom < ActiveRecord::Migration[6.1]
  def change
    add_column  :rooms, :building_name, :string
  end
end
