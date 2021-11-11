class AddDeptGroupDescriptionToRoom < ActiveRecord::Migration[6.1]
  def change
    add_column  :rooms, :dept_group_description, :string
  end
end
