class AddAdaColumnToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column  :rooms, :ada_seat_count, :integer
  end
end
