class AddPrimaryKeyToRoomContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :room_contacts, :id, :primary_key
  end
end
