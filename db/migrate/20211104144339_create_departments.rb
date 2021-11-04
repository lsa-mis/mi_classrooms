class CreateDepartments < ActiveRecord::Migration[6.1]
  def change
    create_table :departments do |t|
      t.integer :dept_id
      t.string :dept_grp
      t.string :dept_description
      t.string :dept_group_description

      t.timestamps
    end
  end
end
