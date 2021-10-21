class AddUniqnameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column  :users, :uniqname, :string
    add_index :users, :uniqname, unique: true
  end
end
