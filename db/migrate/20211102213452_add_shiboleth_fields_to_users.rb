class AddShibolethFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :principal_name, :string
    add_column :users, :display_name, :string
    add_column :users, :person_affiliation, :string
  end
end
