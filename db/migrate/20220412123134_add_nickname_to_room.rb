class AddNicknameToRoom < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :nickname, :string
  end
end
