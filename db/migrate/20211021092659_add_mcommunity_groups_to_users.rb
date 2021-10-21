class AddMcommunityGroupsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :mcommunity_groups, :text, default: "", null: false
  end
end
